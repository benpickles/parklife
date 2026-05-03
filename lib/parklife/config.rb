# frozen_string_literal: true
require 'pathname'
require 'stringio'
require 'uri'
require_relative 'logger'
require_relative 'reporter/log'
require_relative 'reporter/null'
require_relative 'reporter/progress'

module Parklife
  class Config
    CACHE_TMPDIR = 'tmp/parklife/cache'
    DEFAULT_HOST = 'example.com'
    DEFAULT_SCHEME = 'http'

    attr_accessor :app, :logger, :nested_index, :on_404, :skip_build_meta
    attr_reader :base, :build_dir, :cache_dir, :no_colour, :reporter

    def initialize
      self.base = nil
      self.build_dir = 'build'
      self.cache_dir = nil
      self.logger = Logger.new
      self.nested_index = true
      self.no_colour = false
      self.on_404 = :error
      self.reporter = 'null'
      self.skip_build_meta = false
    end

    def base=(value)
      uri = URI === value ? value : URI.parse(value || '')
      uri.host ||= DEFAULT_HOST
      uri.scheme ||= DEFAULT_SCHEME
      @base = uri
    end

    def build_dir=(value)
      @build_dir = Pathname.new(value)
    end

    def cache_dir=(value)
      @cache_dir = value ? Pathname.new(value) : nil
    end

    def no_colour=(value)
      @no_colour = logger.no_colour = value
    end

    def reporter=(value)
      @reporter = case value
      when 'log'
        Reporter::Log.new(logger)
      when 'progress'
        Reporter::Progress.new(logger)
      else
        Reporter::Null.new(logger)
      end
    end
  end
end
