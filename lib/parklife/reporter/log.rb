# frozen_string_literal: true
require_relative 'base'

module Parklife
  module Reporter
    class Log < Base
      def visit(route, response)
        status = response.status
        puts "#{colour(status, *STATUS_COLOUR[status])} #{route.path}"
      end
    end
  end
end
