# frozen_string_literal: true
RSpec.describe Parklife::Responder::NotModified do
  subject { described_class.new(crawler) }

  let(:build_dir) { Dir.mktmpdir }
  let(:config) {
    c = Parklife::Config.new
    c.build_dir = build_dir
    c
  }
  let(:crawl) { false }
  let(:crawler) { Parklife::Crawler.new(config, [], cache) }
  let(:response) { Rack::MockResponse.new(304, {}, '') }
  let(:route) { Parklife::Route.new('/foo', crawl: crawl) }

  context 'when a valid cache is configured' do
    let(:cache) { Parklife::Build.new(config.cache_dir, nested_index: config.nested_index) }
    let(:cache_dir) { Dir.mktmpdir }

    before do
      config.cache_dir = cache_dir
    end

    context 'and it contains a matching route' do
      before do
        cache.add(
          route,
          Rack::MockResponse.new(200, {}, '<a href="/bar">bar</a> <a href="/baz">baz</a>')
        )
      end

      context 'for a non-crawl route' do
        it 'adds the response to the build' do
          expect {
            subject.call(route, response)
          }.not_to change(crawler, :routes)

          expect(build_files).to contain_exactly('foo/index.html')
        end
      end

      context 'for a crawl route' do
        let(:crawl) { true }

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

    context 'but it does not contain a matching route' do
      before do
        cache.add(
          Parklife::Route.new('/another', crawl: false),
          Rack::MockResponse.new(200, {}, 'foo')
        )
      end

      it 'does nothing' do
        expect {
          subject.call(route, response)
        }.not_to change(crawler, :routes)

        expect(build_files).to be_empty
      end
    end
  end

  context 'when a cache is not configured' do
    let(:cache) { nil }

    it 'does nothing' do
      expect {
        subject.call(route, response)
      }.not_to change(crawler, :routes)

      expect(build_files).to be_empty
    end
  end
end
