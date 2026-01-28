# frozen_string_literal: true

require 'parklife/browser'
require 'parklife/route'
require 'parklife/utils'
require 'set'

module Parklife
  class Crawler
    attr_reader :browser, :config, :route_set

    def initialize(config, route_set)
      @config = config
      @route_set = route_set
      @browser = Browser.new(config.app, config.base)
    end

    def get(path)
      browser.get(path)
    end

    def start
      @routes = route_set.to_a
      @visited = Set.new

      while (route = @routes.shift)
        processed = process_route(route)
        config.reporter.print('.') if processed
      end

      config.reporter.puts
    end

    private
      def process_route(route)
        already_processed = if route.crawl
          # No need to re-process an already-crawled route (but do re-process
          # a route that has been visited but not crawled).
          @visited.include?(route)
        else
          # This route isn't being crawled so there's no need to re-process
          # it if it has already been visited or crawled.
          crawled_route = Route.new(route.path, crawl: true)
          @visited.include?(route) || @visited.include?(crawled_route)
        end

        return false if already_processed

        response = get(route.path)

        case response.status
        when 200
          Utils.save_page(route.path, response.body, config)
        when 301, 302
          raise HTTPRedirectError.new(
            response.status,
            browser.uri_for(route.path),
            response.headers['location']
          )
        when 404
          case config.on_404
          when :warn
            $stderr.puts HTTPError.new(404, route.path).message
          when :skip
            return false
          else
            raise HTTPError.new(404, route.path)
          end
        else
          raise HTTPError.new(response.status, route.path)
        end

        @visited << route

        if route.crawl
          Utils.scan_for_links(response.body) do |path|
            # When an app is mounted at a path it responds to URLs that must
            # exclude the mount path but it generates links that include it (if
            # it is correctly configured). This prefix must therefore be
            # stripped from links discovered via crawling.
            baseless_path = path.delete_prefix(config.base.path)

            route = Route.new(baseless_path, crawl: true)

            # Don't revisit the route if it has already been visited with
            # crawl=true but do revisit if it wasn't crawled.
            next if @visited.include?(route)

            @routes << route
          end
        end

        true
      end
  end
end
