# frozen_string_literal: true

require 'parklife/utils'
require 'rack/test'

module Parklife
  class Browser
    attr_reader :app, :base, :env, :session

    def initialize(app, base)
      @app = app
      @base = base
      @session = Rack::Test::Session.new(app)
      @env = {
        'HTTP_HOST' => Utils.host_with_port(base),
        'HTTPS' => base.scheme == 'https' ? 'on' : 'off',
        script_name: base.path.chomp('/'),
      }
    end

    def get(path, headers: nil)
      session.get(
        path,
        nil,
        headers ? headers.merge(env) : env
      )
    end

    def uri_for(path)
      base.dup.tap { |uri| uri.path = path }
    end
  end
end
