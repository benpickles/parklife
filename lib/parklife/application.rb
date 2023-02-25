require 'fileutils'
require 'parklife/config'
require 'parklife/crawler'
require 'parklife/errors'
require 'parklife/route_set'

module Parklife
  class Application
    attr_reader :config, :crawler

    def initialize
      @config = Config.new
      @route_set = RouteSet.new
      @crawler = Crawler.new(config, @route_set)
    end

    def build
      raise BuildDirNotDefinedError if config.build_dir.nil?
      raise RackAppNotDefinedError if config.app.nil?

      FileUtils.rm_rf(config.build_dir)
      Dir.mkdir(config.build_dir)

      crawler.start
    end

    def configure
      yield config
    end

    def routes(&block)
      if block_given?
        @route_set.instance_eval(&block)
      else
        @route_set
      end
    end
  end
end
