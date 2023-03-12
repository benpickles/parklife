# frozen_string_literal: true

require 'set'
require_relative 'route'

module Parklife
  class RouteSet
    include Enumerable

    attr_reader :routes

    def initialize
      @routes = Set.new
    end

    def each
      routes.each do |path|
        yield path
      end
    end

    def get(path, crawl: false)
      routes << Route.new(path, crawl: crawl)
    end

    def root(crawl: false)
      get('/', crawl: crawl)
    end

    def size
      routes.size
    end

    def to_a
      routes.to_a
    end
  end
end
