raise Parklife::RailsNotDefinedError unless defined?(Rails)

module Parklife
  module RailsConfigRefinements
    # When setting Parklife's base also configure the Rails app's
    # default_url_options to match.
    def base=(value)
      super.tap { |uri|
        Rails.application.default_url_options = {
          host: Utils.host_with_port(uri),
          protocol: uri.scheme,
        }
      }
    end
  end
end

Parklife.application.config.app = Rails.application

# Allow use of the Rails application's route helpers when defining Parklife
# routes in the block form.
Parklife.application.routes.singleton_class.include(Rails.application.routes.url_helpers)

Parklife.application.config.extend(Parklife::RailsConfigRefinements)
