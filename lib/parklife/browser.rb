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

    private
      def set_env
        host = base.host
        default_port = base.scheme == 'https' ? 443 : 80
        host += ":#{base.port}" unless base.port == default_port

        @env = {
          'HTTP_HOST' => host,
          'HTTPS' => base.scheme == 'https' ? 'on' : 'off',
          script_name: base.path.chomp('/'),
        }
      end
  end
end
