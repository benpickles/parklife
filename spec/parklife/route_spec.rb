# frozen_string_literal: true
require 'parklife/route'

RSpec.describe Parklife::Route do
  describe '#with_crawl' do
    let(:route) { described_class.new('/foo', crawl: crawl) }

    context 'when crawl=true' do
      let(:crawl) { true }

      it 'returns itself' do
        expect(route.with_crawl).to be(route)
      end
    end

    context 'when crawl=false' do
      let(:crawl) { false }

      it 'returns a Route with the same path and crawl=true' do
        new_route = route.with_crawl
        expect(new_route.crawl).to be(true)
        expect(new_route.path).to eql(route.path)
      end
    end
  end
end
