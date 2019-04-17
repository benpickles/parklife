require 'capybara'
require 'fileutils'
require 'parklife/errors'
require 'parklife/null_reporter'
require 'parklife/route_set'
require 'parklife/utils'

module Parklife
  class Application
    attr_accessor :build_dir, :rack_app, :reporter

    def initialize(build_dir: nil, rack_app: nil, reporter: NullReporter.new)
      @build_dir = build_dir
      @rack_app = rack_app
      @reporter = reporter
      @after_build_callbacks = []
      @before_build_callbacks = []
      @routes = RouteSet.new
    end

    def after_build(&block)
      @after_build_callbacks << block
    end

    def before_build(&block)
      @before_build_callbacks << block
    end

    def build
      raise BuildDirNotDefinedError if build_dir.nil?
      raise RackAppNotDefinedError if rack_app.nil?

      Capybara.save_path = build_dir

      FileUtils.rm_rf(build_dir)
      Dir.mkdir(build_dir)

      before_build_callbacks.each do |callback|
        callback.call(self)
      end

      size = routes.size
      reporter.puts "Building #{size} route#{'s' unless size == 1}"

      routes.each do |route|
        session.visit(route)

        if session.status_code != 200
          raise HTTPError.new(path: route, status: session.status_code)
        end

        session.save_page(Utils.build_path_for(dir: build_dir, path: route))
        reporter.print '.'
      end

      reporter.puts

      after_build_callbacks.each do |callback|
        callback.call(self)
      end
    end

    def routes(&block)
      if block_given?
        @routes.instance_eval(&block)
      else
        @routes
      end
    end

    private
      attr_reader :after_build_callbacks, :before_build_callbacks

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
