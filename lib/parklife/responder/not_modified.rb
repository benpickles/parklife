# frozen_string_literal: true
require_relative 'base'

module Parklife
  module Responder
    class NotModified < Base
      def call(route, response)
        pathname = crawler.cache&.get(route, response)

        return unless pathname&.exist?

        crawler.build.copy(pathname, route, response)
        crawler.crawl(pathname.read) if route.crawl
      end
    end
  end
end
