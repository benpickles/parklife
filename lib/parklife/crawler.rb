# frozen_string_literal: true
require 'parklife/browser'
require 'parklife/build'
require 'parklife/route'
require 'parklife/utils'
require 'set'

module Parklife
  class Crawler
    attr_reader :browser, :build, :config, :route_set, :visited

    def initialize(config, route_set)
      @config = config
      @route_set = route_set
      @browser = Browser.new(config.app, config.base)
      @build = Build.new(config.build_dir, nested_index: config.nested_index)
      @visited = Set.new
    end

    def get(path)
      browser.get(path)
    end

    def start
      @routes = route_set.to_a

      while (route = @routes.shift)
        processed = process_route(route)
        config.reporter.print('.') if processed
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

    private
      def process_route(route)
        return false if visited?(route)

        response = get(route.path)

        case response.status
        when 200
          build.add(route, response)
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
            next if visited?(route)

            @routes << route
          end
        end

        true
      end
  end
end
