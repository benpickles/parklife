require 'parklife/application'

RSpec.describe 'Parklife::Rails' do
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
    end

    it 'gives access to Rails URL helpers when defining routes' do
      load(path_to_rails)

      parklife_app.routes do
        get foo_path
      end

      route = Parklife::Route.new('/foo', crawl: false)
      expect(parklife_app.routes).to include(route)
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
