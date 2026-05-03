# frozen_string_literal: true
require_relative 'base'

module Parklife
  module Responder
    class NotFound < Base
      def call(route, response)
        case crawler.config.on_404
        when :skip
          # No-op.
        when :warn
          crawler.config.logger.warn(
            HTTPError.new(response.status, route.path).message
          )
        else
          raise HTTPError.new(response.status, route.path)
        end
      end
    end
  end
end
