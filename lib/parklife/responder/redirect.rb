# frozen_string_literal: true
require_relative 'base'

module Parklife
  module Responder
    class Redirect < Base
      def call(route, response)
        raise HTTPRedirectError.new(
          response.status,
          crawler.browser.uri_for(route.path),
          response.headers['location']
        )
      end
    end
  end
end
