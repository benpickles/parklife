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
      set_env
    end

    def get(path)
      session.get(path, nil, env)
    end

    def uri_for(path)
      base.dup.tap { |uri| uri.path = path }
    end

    private
      def set_env
        @env = {
          'HTTP_HOST' => Utils.host_with_port(base),
          'HTTPS' => base.scheme == 'https' ? 'on' : 'off',
          script_name: base.path.chomp('/'),
        }
      end
  end
end
