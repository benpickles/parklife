# frozen_string_literal: true
module Parklife
  module Rails
    module ConfigRefinements
      # When setting Parklife's base also configure the Rails app's
      # default_url_options and relative_url_root to match.
      def base=(value)
        super.tap { |uri|
          app.default_url_options = {
            host: Utils.host_with_port(uri),
            protocol: uri.scheme,
          }

          base_path = !uri.path.empty? && uri.path != '/' ? uri.path : nil
          ActionController::Base.relative_url_root = base_path
        }
      end
    end
  end
end
