require 'parklife/application'
require 'tmpdir'

RSpec.describe Parklife::Application do
  describe '#build' do
    let(:endpoint_200) { Proc.new { |env| [200, {}, ['200']] } }
    let(:endpoint_302) { Proc.new { |env| [302, { 'Location' => 'http://example.com/' }, ['302']] } }
    let(:endpoint_500) { Proc.new { |env| [500, {}, ['500']] } }
    let(:tmpdir) { Dir.mktmpdir }

    subject {
      described_class.new.tap { |app|
        app.configure do |config|
          config.build_dir = build_dir
          config.rack_app = rack_app
        end
      }
    }

    context 'when config.build_dir is not set' do
      let(:build_dir) { nil }
      let(:rack_app) { endpoint_200 }

      it do
        expect {
          subject.build
        }.to raise_error(Parklife::BuildDirNotDefinedError)
      end
    end

    context 'when config.rack_app is not set' do
      let(:build_dir) { tmpdir }
      let(:rack_app) { nil }

      it do
        expect {
          subject.build
        }.to raise_error(Parklife::RackAppNotDefinedError)
      end
    end
  end

  describe '#routes' do
    subject { described_class.new }

    it 'works as an object and with a block and can be called many times' do
      expect(subject.routes.size).to eql(0)

      subject.routes.get '/a'

      expect(subject.routes.size).to eql(1)

      subject.routes do
        get '/b'
      end

      expect(subject.routes.size).to eql(2)

      subject.routes do
        get '/c'
      end

      expect(subject.routes.size).to eql(3)

      subject.routes.get '/d'

      expect(subject.routes.size).to eql(4)
    end
  end
end
