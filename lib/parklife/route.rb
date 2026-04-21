# frozen_string_literal: true

module Parklife
  class Route
    attr_reader :crawl, :path

    def initialize(path, crawl:)
      @path = path
      @crawl = crawl
    end

    def ==(other)
      path == other.path && crawl == other.crawl
    end
    alias_method :eql?, :==

    def hash
      [self.class, path, crawl].hash
    end

    def inspect
      %(<#{self.class.name} path="#{path}" crawl="#{crawl}">)
    end

    def with_crawl
      crawl ? self : self.class.new(path, crawl: true)
    end
  end
end
