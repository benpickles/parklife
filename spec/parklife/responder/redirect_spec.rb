# frozen_string_literal: true
RSpec.describe Parklife::Responder::Redirect do
  subject { described_class.new(crawler) }

  let(:browser) { instance_double('Parklife::Browser') }
  let(:config) { Parklife::Config.new }
  let(:crawler) { instance_double('Parklife::Crawler', browser: browser) }
  let(:headers) { { 'location' => 'https://foo.example.org/bar' } }
  let(:response) { Rack::MockResponse.new(301, headers, '') }
  let(:route) { Parklife::Route.new('/redirect-me', crawl: false) }

  it 'raises an informative error' do
    allow(browser).to receive(:uri_for).with('/redirect-me').and_return('http://example.com/redirect-me')

    expect {
      subject.call(route, response)
    }.to raise_error(
      Parklife::HTTPRedirectError,
      '301 redirect from "http://example.com/redirect-me" to "https://foo.example.org/bar"'
    )
  end
end
