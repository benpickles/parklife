require 'ostruct'
require 'parklife/application'

RSpec.describe 'Parklife Rails integration' do
  let(:path_to_rails) { File.expand_path('../../lib/parklife/rails.rb', __dir__) }

  context 'when Rails is defined' do
    let(:action_controller_base) { OpenStruct.new }
    let(:parklife_app) { Parklife::Application.new }
    let(:rails) { double('Rails', application: rails_app) }
    let(:rails_app) {
      OpenStruct.new(
        routes: OpenStruct.new(url_helpers: url_helpers),
      )
    }
    let(:url_helpers) {
      Module.new do
        def foo_path
          '/foo'
        end
      end
    }

    before do
      stub_const('ActionController::Base', action_controller_base)
      stub_const('Rails', rails)
      allow(Parklife).to receive(:application).and_return(parklife_app)
      load(path_to_rails)
    end

    it 'gives access to Rails URL helpers when defining routes' do
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
      expect(action_controller_base.relative_url_root).to eql('/foo')

      parklife_app.config.base = 'http://foo.example.com/'

      expect(rails_app.default_url_options).to eql({
        host: 'foo.example.com',
        protocol: 'http',
      })
      expect(action_controller_base.relative_url_root).to be_nil

      expect {
        another_parklife_app = Parklife::Application.new
        another_parklife_app.config.base = 'https://example.com/foo'
      }.not_to change {
        [rails_app.default_url_options, action_controller_base.relative_url_root]
      }
    end
  end

  context 'when Rails is not defined' do
    it do
      expect {
        load(path_to_rails)
      }.to raise_error(Parklife::RailsNotDefinedError)
    end
  end
end
