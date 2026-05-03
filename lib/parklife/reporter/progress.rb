# frozen_string_literal: true
require_relative 'base'

module Parklife
  module Reporter
    class Progress < Base
      def finish
        puts
      end

      def visit(_route, response)
        print colour('.', *STATUS_COLOUR[response.status])
      end
    end
  end
end
