# frozen_string_literal: true

require 'sinatra/base'

module Sinatra
  module Parklife
    def self.registered(app)
      # Disable Rack::Protection::HostAuthorization middleware so that fetching
      # a page with Parklife works in development. It's safe to do here because
      # it will only be executed when explicitly required in a Parkfile and not
      # when the app is running in a web server.
      if app.settings.respond_to?(:host_authorization)
        app.set(:host_authorization, permitted_hosts: [])
      end
    end
  end

  register Parklife
end
