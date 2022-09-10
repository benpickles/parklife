require 'capybara'
require 'fileutils'
require 'parklife/errors'
require 'parklife/route_set'
require 'parklife/utils'
require 'stringio'

module Parklife
  class Application
    attr_accessor :base, :build_dir, :nested_index, :rack_app, :reporter

    def initialize(base: nil, build_dir: nil, nested_index: true, rack_app: nil, reporter: StringIO.new)
      @base = base
      @build_dir = build_dir
      @nested_index = nested_index
      @rack_app = rack_app
      @reporter = reporter
      @routes = RouteSet.new
    end

    def build
      raise BuildDirNotDefinedError if build_dir.nil?
      raise RackAppNotDefinedError if rack_app.nil?

      Capybara.app_host = base if base
      Capybara.save_path = build_dir

      FileUtils.rm_rf(build_dir)
      Dir.mkdir(build_dir)

      size = routes.size
      reporter.puts "Building #{size} route#{'s' unless size == 1}"

      routes.each do |route|
        session.visit(route)

        if session.status_code != 200
          raise HTTPError.new(path: route, status: session.status_code)
        end

        session.save_page(
          Utils.build_path_for(
            dir: build_dir,
            index: nested_index,
            path: route,
          )
        )
        reporter.print '.'
      end

      reporter.puts
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
          Capybara.register_driver :rack_test do |app|
            Capybara::RackTest::Driver.new(app, follow_redirects: false)
          end

          Capybara::Session.new(:rack_test, rack_app)
        end
      end
  end
end
