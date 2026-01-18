# frozen_string_literal: true
require_relative 'base'

module Parklife
  module Responder
    class Ok < Base
      def call(route, response)
        crawler.build.add(route, response)
        crawler.crawl(response.body) if route.crawl
      end
    end
  end
end
