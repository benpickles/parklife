# frozen_string_literal: true
module Parklife
  module Rails
    module RouteSetRefinements
      def default_url_options
        ::Rails.application.default_url_options
      end
    end
  end
end
