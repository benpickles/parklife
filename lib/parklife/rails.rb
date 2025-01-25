# frozen_string_literal: true

require 'rails'

module Parklife
  module RailsConfigRefinements
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

  module RailsRouteSetRefinements
    def default_url_options
      Rails.application.default_url_options
    end
  end

  class Railtie < Rails::Railtie
    initializer 'parklife.disable_host_authorization' do |app|
      # The offending middleware is included in Rails (6+) development mode and
      # rejects a request with a 403 response if its host isn't present in the
      # allowlist (a security feature). This prevents Parklife from working in
      # a Rails app out of the box unless you manually add the expected
      # Parklife base to the hosts allowlist or set it to nil to disable it -
      # both of which aren't great because they disable the security feature
      # whenever the development server is booted.
      #
      # https://guides.rubyonrails.org/configuring.html#actiondispatch-hostauthorization
      #
      # However it's safe to remove the middleware at this point because it
      # won't be executed in the normal Rails development flow, only via a
      # Parkfile when parklife/rails is required.
      if defined?(ActionDispatch::HostAuthorization)
        app.middleware.delete(ActionDispatch::HostAuthorization)
      end

      Parklife.application.config.app = app

      # Allow use of the Rails application's route helpers when defining
      # Parklife routes in the block form.
      Parklife.application.routes.singleton_class.include(RailsRouteSetRefinements)
      Parklife.application.routes.singleton_class.include(app.routes.url_helpers)

      Parklife.application.config.extend(RailsConfigRefinements)
    end
  end
end
