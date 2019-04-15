require 'parklife'
require 'rack'

app = Proc.new { |env|
  request = Rack::Request.new(env)

  [
    200,
    { 'Content-Type' => 'text/html' },
    ["Served from #{request.path}"]
  ]
}

Parklife.application.build_dir = File.expand_path('build', __dir__)
Parklife.application.rack_app = app

Parklife.application.routes do
  root
  get 'foo'
  get 'bar'
end
