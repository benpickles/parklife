# frozen_string_literal: true
require 'set'
require_relative 'browser'
require_relative 'build'
require_relative 'responder/not_found'
require_relative 'responder/not_modified'
require_relative 'responder/ok'
require_relative 'responder/redirect'
require_relative 'responder/unknown'
require_relative 'route'
require_relative 'utils'

module Parklife
  class Crawler
    RESPONDERS = {
      200 => Responder::Ok,
      301 => Responder::Redirect,
      302 => Responder::Redirect,
      304 => Responder::NotModified,
      404 => Responder::NotFound,
    }

    attr_reader :browser, :build, :cache, :config, :routes, :visited

    def initialize(config, routes, cache)
      @config = config
      @routes = routes.to_a
      @cache = cache
      @browser = Browser.new(config.app, config.base)
      @build = Build.new(config.build_dir, nested_index: config.nested_index)
      @visited = Set.new
      @responder_for_status = {}
    end

    def crawl(html)
      Utils.scan_for_links(html) do |path|
        # If the app is mounted at a subdirectory then it responds to paths that
        # *exclude* the subdirectory and generates links that *include* the
        # subdirectory (so if the app is mounted at "/foo" and serving "/bar"
        # then the full path would be "/foo/bar" and a generated link would
        # include the mount path like "/foo/link").
        #
        # Anyway, this mount path prefix must be trimmed from link paths so that
        # correct app routes are created.
        baseless_path = path.delete_prefix(config.base.path)
        new_route = Route.new(baseless_path, crawl: true)

        next if visited?(new_route)

        routes << new_route
      end
    end

    def get(path)
      headers = if (etag = cache&.etag(path))
        { 'HTTP_IF_NONE_MATCH' => etag }
      else
        nil
      end

      browser.get(path, headers: headers)
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
    ensure
      build.write_meta unless config.skip_build_meta
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
        @visited.include?(route) || @visited.include?(route.with_crawl)
      end
    end
  end
end
