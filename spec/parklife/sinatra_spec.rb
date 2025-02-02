require 'parklife/sinatra'

RSpec.describe 'Parklife Sinatra integration' do
  include Rack::Test::Methods

  let(:app) {
    Class.new(Sinatra::Base) do
      get '/' do
        'foo'
      end
    end
  }

  def initialize!
    app.register(Parklife::Sinatra)
  end

  it 'disables host authorization middleware' do
    initialize!
    get '/'
    expect(last_response.status).to be(200)
  end
end
