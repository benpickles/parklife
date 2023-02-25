require 'parklife/browser'

RSpec.describe Parklife::Browser do
  describe '.new setting up the correct #env' do
    let(:app) { Proc.new {} }
    let(:browser) { described_class.new(app, uri) }

    context 'when the URL has no path' do
      let(:uri) { URI.parse('http://foo.example.com') }

      it do
        expect(browser.env['HTTP_HOST']).to eql('foo.example.com')
        expect(browser.env['HTTPS']).to eql('off')
      end
    end

    context 'with an https URL with a path' do
      let(:uri) { URI.parse('https://bar.example.com/baz') }

      it do
        expect(browser.env['HTTP_HOST']).to eql('bar.example.com')
        expect(browser.env['HTTPS']).to eql('on')
      end
    end
  end

  describe '#get' do
    let(:app) {
      Proc.new { |env|
        request = Rack::Request.new(env)
        status = case env['PATH_INFO']
        when '/404'
          404
        else
          200
        end
        [status, {}, [request.url]]
      }
    }
    let(:base) { URI.parse('https://foo.example.com') }
    let(:browser) { described_class.new(app, base) }

    it 'sends the correct host/scheme' do
      response = browser.get('/foo')
      expect(response.body).to eql('https://foo.example.com/foo')
      expect(response.status).to eql(200)

      response = browser.get('/404')
      expect(response.body).to eql('https://foo.example.com/404')
      expect(response.status).to eql(404)
    end
  end
end
