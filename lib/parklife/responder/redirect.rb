# frozen_string_literal: true
require_relative 'base'

module Parklife
  module Responder
    class Redirect < Base
      def call(route, response)
        status = response.status
        setting = setting_for_status(status)

        case setting
        when :skip
          # No-op.
        when :warn
          crawler.config.logger.warn(
            HTTPRedirectError.new(
              status,
              crawler.browser.uri_for(route.path),
              response.headers['location']
            ).message
          )
        else
          raise HTTPRedirectError.new(
            status,
            crawler.browser.uri_for(route.path),
            response.headers['location']
          )
        end
      end

      private
        def setting_for_status(status)
          case status
          when 301
            crawler.config.on_301
          when 302
            crawler.config.on_302
          end
        end
    end
  end
end
