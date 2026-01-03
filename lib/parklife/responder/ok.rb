# frozen_string_literal: true
require_relative 'base'
require_relative '../route'
require_relative '../utils'

module Parklife
  module Responder
    class Ok < Base
      def call(route, response)
        crawler.build.add(route, response)

        return unless route.crawl

        Utils.scan_for_links(response.body) do |path|
          # If the app is mounted at a subdirectory then it responds to paths
          # that *exclude* the subdirectory and generates links that *include*
          # the subdirectory (so if the app is mounted at "/foo" and serving
          # "/bar" then the full path would be "/foo/bar" and a generated link
          # would include the mount path like "/foo/link").
          #
          # Anyway, this mount path prefix must be trimmed from link paths so
          # that correct app routes are created.
          baseless_path = path.delete_prefix(crawler.config.base.path)
          new_route = Route.new(baseless_path, crawl: true)

          next if crawler.visited?(new_route)

          crawler.routes << new_route
        end
      end
    end
  end
end
