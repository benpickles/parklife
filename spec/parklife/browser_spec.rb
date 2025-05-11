require 'parklife/browser'

RSpec.describe Parklife::Browser do
  describe '#get' do
    let(:app) {
      Proc.new { |env|
        status = case env['PATH_INFO']
        when '/404'
          404
        else
          200
        end

        request = Rack::Request.new(env)
        body = [
          env['rack.url_scheme'],
          env['HTTP_HOST'],
          env['PATH_INFO'],
          request.url
        ].join(',')

        [status, {}, [body]]
      }
    }
    let(:browser) { described_class.new(app, base) }

    context 'when the base has no path' do
      let(:base) { URI.parse('http://example.com') }

      it do
        response = browser.get('/foo')
        expect(response.body).to eql('http,example.com,/foo,http://example.com/foo')
        expect(response.status).to eql(200)

        response = browser.get('/404')
        expect(response.body).to eql('http,example.com,/404,http://example.com/404')
        expect(response.status).to eql(404)
      end
    end

    context 'when the base has a path' do
      let(:base) { URI.parse('https://foo.example.com/bar') }

      it 'strips it from the passed path' do
        response = browser.get('/baz')
        expect(response.body).to eql('https,foo.example.com,/baz,https://foo.example.com/bar/baz')
      end
    end

    context 'when the base has a non-standard port' do
      let(:base) { URI.parse('http://localhost:3000') }

      it do
        response = browser.get('/foo')
        expect(response.body).to eql('http,localhost:3000,/foo,http://localhost:3000/foo')
      end
    end
  end

  describe '#uri_for' do
    it 'returns a new URI with the supplied path' do
      base = URI.parse('http://example.org')
      browser = described_class.new(nil, base)
      uri_for = browser.uri_for('/foo')

      expect(uri_for.to_s).to eql('http://example.org/foo')
      expect(uri_for).not_to be(base)
    end
  end
end
