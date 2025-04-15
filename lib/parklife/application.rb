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
      @after_build_callbacks = []
      @before_build_callbacks = []
    end

    def after_build(&block)
      @after_build_callbacks << block
    end

    def before_build(&block)
      @before_build_callbacks << block
    end

    def build
      raise BuildDirNotDefinedError if config.build_dir.nil?
      raise RackAppNotDefinedError if config.app.nil?

      if Dir.exist?(config.build_dir)
        FileUtils.rm_rf(
          Dir.glob(
            File.join(config.build_dir, '*'),
            File::FNM_DOTMATCH
          )
        )
      else
        Dir.mkdir(config.build_dir)
      end

      @before_build_callbacks.each do |callback|
        callback.call(self)
      end

      crawler.start

      @after_build_callbacks.each do |callback|
        callback.call(self)
      end
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
