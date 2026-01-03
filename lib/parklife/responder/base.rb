# frozen_string_literal: true
module Parklife
  module Responder
    class Base
      attr_reader :crawler

      def initialize(crawler)
        @crawler = crawler
      end

      def call(route, response)
      end
    end
  end
end
