require 'parklife/route_set'

RSpec.describe Parklife::RouteSet do
  describe '#get' do
    subject { described_class.new }

    context 'when adding the same route more than once' do
      it do
        subject.get '/'
        subject.get '/', crawl: false
        subject.get '/'

        expect(subject.size).to eql(1)

        subject.get '/', crawl: true
        subject.get '/', crawl: true

        expect(subject.size).to eql(2)
      end
    end
  end
end
