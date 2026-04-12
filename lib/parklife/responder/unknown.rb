# frozen_string_literal: true
require_relative 'base'

module Parklife
  module Responder
    class Unknown < Base
      def call(route, response)
        raise HTTPError.new(response.status, route.path)
      end
    end
  end
end
