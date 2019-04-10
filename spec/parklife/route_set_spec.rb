require 'parklife/route_set'

RSpec.describe Parklife::RouteSet do
  describe '#get' do
    subject { described_class.new }

    context 'when adding the same route more than once' do
      it do
        subject.get '/'
        subject.get '/'

        expect(subject.size).to eql(1)
      end
    end
  end
end
