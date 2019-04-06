require 'set'

module Parklife
  class RouteSet
    attr_reader :routes

    def initialize
      @routes = Set.new([])
    end

    def each
      routes.each do |path|
        yield path
      end
    end

    def get(path)
      routes << path
    end

    def root
      get('/')
    end

    def size
      routes.size
    end

    def to_a
      routes.to_a
    end
  end
end
