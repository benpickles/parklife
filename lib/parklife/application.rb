require 'capybara'
require 'fileutils'
require 'parklife/route_set'
require 'parklife/utils'
require 'rack/builder'

module Parklife
  class Application
    attr_accessor :build_dir
    attr_reader :rack_app

    def initialize
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
      Capybara.save_path = build_dir

      FileUtils.rm_rf(build_dir)

      before_build_callbacks.each do |callback|
        callback.call(self)
      end

      size = routes.size
      puts "Building #{size} route#{'s' unless size == 1}"

      routes.each do |route|
        session.visit(route)
        session.save_page(Utils.build_path(build_dir, route))
        print '.'
      end

      puts

      after_build_callbacks.each do |callback|
        callback.call(self)
      end
    end

    def rack_app=(app)
      @rack_app = Rack::Builder.new do
        map '/' do
          run app
        end
      end.to_app
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
        @session ||= Capybara::Session.new(:rack_test, rack_app)
      end
  end
end
