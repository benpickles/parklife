require 'action_controller'
require 'parklife/application'
require 'parklife/rails'

RSpec.describe 'Parklife Rails integration' do
  let(:parklife_app) { Parklife::Application.new }
  let(:rails_app) {
    Class.new(Rails::Application) do
      config.eager_load = false
      config.logger = Logger.new('/dev/null')
    end
  }

  before do
    allow(Parklife).to receive(:application).and_return(parklife_app)
    Rails.application = rails_app
    Rails.application.initialize!
  end

  after do
    ActiveSupport::Dependencies.autoload_paths = []
    ActiveSupport::Dependencies.autoload_once_paths = []
  end

  it 'gives access to Rails URL helpers when defining routes' do
    rails_app.routes.draw do
      get :foo, to: proc { [200, {}, 'foo'] }
    end

    parklife_app.routes do
      get foo_path
    end

    route = Parklife::Route.new('/foo', crawl: false)
    expect(parklife_app.routes).to include(route)

    another_parklife_app = Parklife::Application.new

    expect {
      another_parklife_app.routes do
        get foo_path
      end
    }.to raise_error(NameError, /foo_path/)
  end

  it 'configures Rails default_url_options and relative_url_root when setting Parklife base' do
    parklife_app.config.base = 'https://localhost:3000/foo'

    expect(rails_app.default_url_options).to eql({
      host: 'localhost:3000',
      protocol: 'https',
    })
    expect(ActionController::Base.relative_url_root).to eql('/foo')

    parklife_app.config.base = 'http://foo.example.com/'

    expect(rails_app.default_url_options).to eql({
      host: 'foo.example.com',
      protocol: 'http',
    })
    expect(ActionController::Base.relative_url_root).to be_nil

    expect {
      another_parklife_app = Parklife::Application.new
      another_parklife_app.config.base = 'https://example.com/foo'
    }.not_to change {
      [rails_app.default_url_options, ActionController::Base.relative_url_root]
    }
  end

  it 'removes host authorization middleware' do
    expect(Rails.application.middleware).not_to include(ActionDispatch::HostAuthorization)
  end
end
