require 'capybara'
require 'parklife/utils'

module Parklife
  class Crawler
    attr_reader :config, :route_set

    def initialize(config, route_set)
      @config = config
      @route_set = route_set

      Capybara.register_driver :parklife do |app|
        Capybara::RackTest::Driver.new(app, follow_redirects: false)
      end
    end

    def start
      Capybara.app_host = config.base if config.base
      Capybara.save_path = config.build_dir

      route_set.each do |route|
        process_route(route)
      end
    end

    private
      def process_route(route)
        session.visit(route)

        if session.status_code != 200
          raise HTTPError.new(path: route, status: session.status_code)
        end

        session.save_page(
          Utils::build_path_for(
            dir: config.build_dir,
            path: route,
            index: config.nested_index,
          )
        )
      end

      def session
        @session ||= Capybara::Session.new(:parklife, config.rack_app)
      end
  end
end
