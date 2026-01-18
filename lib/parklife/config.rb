# frozen_string_literal: true
require 'pathname'
require 'stringio'
require 'uri'

module Parklife
  class Config
    DEFAULT_HOST = 'example.com'
    DEFAULT_SCHEME = 'http'

    attr_accessor :app, :nested_index, :on_404, :reporter, :skip_build_meta
    attr_reader :base, :build_dir, :cache_dir

    def initialize
      self.base = nil
      self.build_dir = 'build'
      self.cache_dir = nil
      self.nested_index = true
      self.on_404 = :error
      self.reporter = StringIO.new
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
  end
end
