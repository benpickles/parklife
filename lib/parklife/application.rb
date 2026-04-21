# frozen_string_literal: true

require 'fileutils'
require 'parklife/build'
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
      raise RackAppNotDefinedError if config.app.nil?

      prepare_cache_dir if config.cache_dir
      prepare_build_dir

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
      @crawler ||= Crawler.new(
        config,
        @route_set,
        config.cache_dir ? Build.from_dir(config.cache_dir) : nil
      )
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

    private
      def prepare_build_dir
        if config.build_dir.directory?
          FileUtils.rm_rf(config.build_dir.children)
        else
          config.build_dir.mkdir
        end
      end

      def prepare_cache_dir
        # Nothing to do unless the previous build is being used as a cache.
        return unless config.cache_dir.expand_path == config.build_dir.expand_path

        if config.build_dir.exist?
          config.cache_dir = Config::CACHE_TMPDIR

          if config.cache_dir.exist?
            config.cache_dir.rmtree
          else
            config.cache_dir.dirname.mkpath
          end

          # Move the existing previous build to the tmp location to clear the
          # way for a fresh new build.
          config.build_dir.rename(config.cache_dir)
        else
          # The build/cache directories are set to the same thing but don't
          # exist so there is no cache.
          config.cache_dir = nil
        end
      end
  end
end
