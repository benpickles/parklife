# frozen_string_literal: true
RSpec.describe Parklife::Responder::Unknown do
  subject { described_class.new(crawler) }

  let(:crawler) { instance_double('Parklife::Crawler') }
  let(:response) { Rack::MockResponse.new(500, {}, '') }
  let(:route) { Parklife::Route.new('/foo/bar', crawl: false) }

  it 'raises an informative error' do
    expect {
      subject.call(route, response)
    }.to raise_error(Parklife::HTTPError, '500 response from path "/foo/bar"')
  end
end
