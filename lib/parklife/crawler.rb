require 'capybara'
require 'parklife/route'
require 'parklife/utils'
require 'set'

module Parklife
  class Crawler
    attr_reader :config, :route_set

    def initialize(config, route_set)
      @config = config
      @route_set = route_set

      Capybara.register_driver :parklife do |app|
        Capybara::RackTest::Driver.new(app, follow_redirects: false)
      end
    end

    def start
      Capybara.app_host = config.base if config.base
      Capybara.save_path = config.build_dir

      @routes = route_set.to_a
      @visited = Set.new

      while route = @routes.shift
        process_route(route)
        config.reporter.print '.'
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

        return if already_processed

        session.visit(route.path)

        case session.status_code
        when 200
          # Continue processing the route.
        when 404
          case config.on_404
          when :error
            raise HTTPError.new(path: route.path, status: 404)
          when :warn
            $stderr.puts HTTPError.new(path: route.path, status: 404).message
          end
        else
          raise HTTPError.new(path: route.path, status: session.status_code)
        end

        session.save_page(
          Utils.build_path_for(
            dir: config.build_dir,
            path: route.path,
            index: config.nested_index,
          )
        )

        @visited << route

        if route.crawl
          Utils.scan_for_links(session.html) do |path|
            route = Route.new(path, crawl: true)

            # Don't revisit the route if it has already been visited with
            # crawl=true but do revisit if it wasn't crawled.
            next if @visited.include?(route)

            @routes << route
          end
        end
      end

      def session
        @session ||= Capybara::Session.new(:parklife, config.rack_app)
      end
  end
end
