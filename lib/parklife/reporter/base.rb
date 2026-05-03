# frozen_string_literal: true
require 'forwardable'

module Parklife
  module Reporter
    class Base
      STATUS_COLOUR = {
        200 => :green,
        304 => :blue,
        404 => :yellow,
      }

      extend Forwardable

      attr_reader :logger

      def initialize(logger)
        @logger = logger
      end

      def_delegators :@logger, :colour, :print, :puts

      def finish
      end

      def visit(_route, _response)
      end
    end
  end
end
