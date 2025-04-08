# frozen_string_literal: true
require 'rails'
require_relative 'rails/config_refinements'
require_relative 'rails/route_set_refinements'

module Parklife
  module Rails
    class Railtie < ::Rails::Railtie
      initializer 'parklife.integration' do |app|
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
        Parklife.application.routes.singleton_class.include(RouteSetRefinements)
        Parklife.application.routes.singleton_class.include(app.routes.url_helpers)

        Parklife.application.config.extend(ConfigRefinements)
      end

      config.after_initialize do |app|
        # Read the Rails app's URL config and apply it to Parklife's so that the
        # Rails config can be used as the single source of truth.
        host, protocol = app.default_url_options.values_at(:host, :protocol)
        protocol = 'https' if app.config.force_ssl
        path = ActionController::Base.relative_url_root

        Parklife.application.config.base.scheme = protocol if protocol
        Parklife.application.config.base.host = host if host
        Parklife.application.config.base.path = path if path
      end
    end
  end
end
