# frozen_string_literal: true
RSpec.describe Parklife::Responder::Redirect do
  subject { described_class.new(crawler) }

  let(:browser) { instance_double('Parklife::Browser') }
  let(:config) { Parklife::Config.new }
  let(:crawler) { instance_double('Parklife::Crawler', browser: browser, config: config) }
  let(:headers) { { 'location' => 'https://foo.example.org/bar' } }
  let(:response) { Rack::MockResponse.new(status, headers, '') }
  let(:route) { Parklife::Route.new('/redirect-me', crawl: false) }

  before do
    allow(browser).to receive(:uri_for).with('/redirect-me').and_return('http://example.com/redirect-me')
  end

  context 'with a 301 response status' do
    let(:status) { 301 }

    context 'when on_301=:error' do
      before { config.on_301 = :error }

      it 'raises an informative error' do
        expect {
          subject.call(route, response)
        }.to raise_error(
          Parklife::HTTPRedirectError,
          '301 redirect from "http://example.com/redirect-me" to "https://foo.example.org/bar"'
        )
      end
    end

    context 'when on_301=:skip' do
      before { config.on_301 = :skip }

      it 'does nothing' do
        expect(config.logger).not_to receive(:warn)
        subject.call(route, response)
      end
    end

    context 'when on_301=:warn' do
      before { config.on_301 = :warn }

      it 'a warning is sent to the logger' do
        expect(config.logger).to receive(:warn).with('301 redirect from "http://example.com/redirect-me" to "https://foo.example.org/bar"')
        subject.call(route, response)
      end
    end
  end

  context 'with a 302 response status' do
    let(:status) { 302 }

    context 'when on_302=:error' do
      before { config.on_302 = :error }

      it 'raises an informative error' do
        expect {
          subject.call(route, response)
        }.to raise_error(
          Parklife::HTTPRedirectError,
          '302 redirect from "http://example.com/redirect-me" to "https://foo.example.org/bar"'
        )
      end
    end

    context 'when on_302=:skip' do
      before { config.on_302 = :skip }

      it 'does nothing' do
        expect(config.logger).not_to receive(:warn)
        subject.call(route, response)
      end
    end

    context 'when on_302=:warn' do
      before { config.on_302 = :warn }

      it 'a warning is sent to the logger' do
        expect(config.logger).to receive(:warn).with('302 redirect from "http://example.com/redirect-me" to "https://foo.example.org/bar"')
        subject.call(route, response)
      end
    end
  end
end
