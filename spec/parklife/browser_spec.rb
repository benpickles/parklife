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
        expect(browser.env[:script_name]).to eql('')
      end
    end

    context 'with an https URL with a path' do
      let(:uri) { URI.parse('https://bar.example.com/baz') }

      it do
        expect(browser.env['HTTP_HOST']).to eql('bar.example.com')
        expect(browser.env['HTTPS']).to eql('on')
        expect(browser.env[:script_name]).to eql('/baz')
      end
    end
  end

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
  end
end
