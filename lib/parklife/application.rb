require 'capybara'
require 'fileutils'
require 'parklife/config'
require 'parklife/errors'
require 'parklife/route_set'
require 'parklife/utils'
require 'stringio'

module Parklife
  class Application
    attr_reader :config

    def initialize
      @config = Config.new
      @routes = RouteSet.new
    end

    def build
      raise BuildDirNotDefinedError if config.build_dir.nil?
      raise RackAppNotDefinedError if config.rack_app.nil?

      Capybara.app_host = config.base if config.base
      Capybara.save_path = config.build_dir

      FileUtils.rm_rf(config.build_dir)
      Dir.mkdir(config.build_dir)

      size = routes.size
      config.reporter.puts "Building #{size} route#{'s' unless size == 1}"

      routes.each do |route|
        session.visit(route)

        if session.status_code != 200
          raise HTTPError.new(path: route, status: session.status_code)
        end

        session.save_page(
          Utils.build_path_for(
            dir: config.build_dir,
            index: config.nested_index,
            path: route,
          )
        )
        config.reporter.print '.'
      end

      config.reporter.puts
    end

    def configure
      yield config
    end

    def routes(&block)
      if block_given?
        @routes.instance_eval(&block)
      else
        @routes
      end
    end

    private
      def session
        @session ||= begin
          Capybara.register_driver :parklife do |app|
            Capybara::RackTest::Driver.new(app, follow_redirects: false)
          end

          Capybara::Session.new(:parklife, config.rack_app)
        end
      end
  end
end
