# frozen_string_literal: true

require 'stringio'
require 'uri'

module Parklife
  class Config
    DEFAULT_HOST = 'example.com'
    DEFAULT_SCHEME = 'http'

    attr_accessor :app, :build_dir, :nested_index, :on_404, :reporter
    attr_reader :base

    def initialize
      self.base = nil
      self.build_dir = 'build'
      self.nested_index = true
      self.on_404 = :error
      self.reporter = StringIO.new
    end

    def base=(value)
      uri = URI.parse(value || '')
      uri.host ||= DEFAULT_HOST
      uri.scheme ||= DEFAULT_SCHEME
      @base = uri
    end
  end
end
