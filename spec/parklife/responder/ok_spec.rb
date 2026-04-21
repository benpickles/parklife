# frozen_string_literal: true
RSpec.describe Parklife::Responder::Ok do
  subject { described_class.new(crawler) }

  let(:build_dir) { Dir.mktmpdir }
  let(:config) {
    c = Parklife::Config.new
    c.build_dir = build_dir
    c
  }
  let(:crawler) { Parklife::Crawler.new(config, []) }
  let(:response) { Rack::MockResponse.new(200, {}, '<a href="/bar">bar</a> <a href="/baz">baz</a>') }

  context 'with a non-crawl route' do
    let(:route) { Parklife::Route.new('/foo', crawl: false) }

    it 'adds the response to the build' do
      expect {
        subject.call(route, response)
      }.not_to change(crawler, :routes)

      expect(build_files).to contain_exactly('foo/index.html')
    end
  end

  context 'with a crawl route' do
    let(:route) { Parklife::Route.new('/foo', crawl: true) }

    it 'adds the response to the build and adds discovered links to the crawler' do
      expect {
        subject.call(route, response)
      }.to change(crawler, :routes).from([]).to([
        Parklife::Route.new('/bar', crawl: true),
        Parklife::Route.new('/baz', crawl: true),
      ])

      expect(build_files).to contain_exactly('foo/index.html')
    end
  end
end
