require 'parklife/application'

RSpec.describe 'Parklife Rails integration' do
  let(:path_to_rails) { File.expand_path('../../lib/parklife/rails.rb', __dir__) }

  context 'when Rails is defined' do
    let(:parklife_app) { Parklife::Application.new }
    let(:rails) { double('Rails', application: rails_app) }
    let(:rails_app) { double('RailsApp') }
    let(:url_helpers) {
      Module.new do
        def foo_path
          '/foo'
        end
      end
    }

    before do
      stub_const('Rails', rails)
      allow(Parklife).to receive(:application).and_return(parklife_app)
      allow(rails_app).to receive_message_chain(:routes, :url_helpers).and_return(url_helpers)
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

    it 'configures Rails default_url_options when setting Parklife base' do
      expect(rails_app).to receive(:default_url_options=).with({
        host: 'localhost:3000',
        protocol: 'https',
      })

      parklife_app.config.base = 'https://localhost:3000'

      expect(rails_app).to receive(:default_url_options=).with({
        host: 'foo.example.com',
        protocol: 'http',
      })

      parklife_app.config.base = 'http://foo.example.com'

      expect(rails_app).not_to receive(:default_url_options=)

      another_parklife_app = Parklife::Application.new
      another_parklife_app.config.base = 'http://example.com'
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
