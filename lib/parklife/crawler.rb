# frozen_string_literal: true
require 'set'
require_relative 'browser'
require_relative 'build'
require_relative 'responder/not_found'
require_relative 'responder/ok'
require_relative 'responder/redirect'
require_relative 'responder/unknown'
require_relative 'route'

module Parklife
  class Crawler
    RESPONDERS = {
      200 => Responder::Ok,
      301 => Responder::Redirect,
      302 => Responder::Redirect,
      404 => Responder::NotFound,
    }

    attr_reader :browser, :build, :config, :routes, :visited

    def initialize(config, routes)
      @config = config
      @routes = routes.to_a
      @browser = Browser.new(config.app, config.base)
      @build = Build.new(config.build_dir, nested_index: config.nested_index)
      @visited = Set.new
      @responder_for_status = {}
    end

    def get(path)
      browser.get(path)
    end

    def responder_for_status(status)
      @responder_for_status[status] ||= RESPONDERS
        .fetch(status, Responder::Unknown)
        .new(self)
    end

    def start
      while (route = routes.shift)
        next if visited?(route)
        response = get(route.path)
        @visited << route
        responder_for_status(response.status).call(route, response)
        config.reporter.print('.')
      end

      config.reporter.puts
    end

    def visited?(route)
      if route.crawl
        # A crawl=true route is only counted as visited when it has already been
        # crawled, if it's been visited by a non-crawl route then it must be
        # visited again so it can be crawled.
        @visited.include?(route)
      else
        # A crawl=false route is counted as visited whether it was previously
        # visited with either a crawl or non-crawl route.
        @visited.include?(route) || @visited.include?(route.as_crawl)
      end
    end
  end
end
