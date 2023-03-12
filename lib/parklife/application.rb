# frozen_string_literal: true

require 'fileutils'
require 'parklife/config'
require 'parklife/crawler'
require 'parklife/errors'
require 'parklife/route_set'

module Parklife
  class Application
    attr_reader :config

    def initialize
      @config = Config.new
      @route_set = RouteSet.new
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

    def crawler
      @crawler ||= Crawler.new(config, @route_set)
    end

    def load_Parkfile(path)
      raise ParkfileLoadError.new(path) unless File.exist?(path)
      load path
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
