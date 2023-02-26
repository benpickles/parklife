require 'rack/test'

module Parklife
  class Browser
    attr_reader :app, :base, :env, :session

    def initialize(app, base)
      @app = app
      @base = base
      @env = {
        'HTTP_HOST' => base.host,
        'HTTPS' => base.scheme == 'https' ? 'on' : 'off',
        script_name: base.path.chomp('/'),
      }
      @session = Rack::Test::Session.new(app)
    end

    def get(path)
      session.get(path, nil, env)
    end
  end
end
