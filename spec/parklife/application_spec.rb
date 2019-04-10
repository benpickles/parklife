require 'parklife/application'
require 'tmpdir'

RSpec.describe Parklife::Application do
  describe '#build' do
    let(:app) { Proc.new { |env| [200, { 'Content-Type' => 'text/html' }, ['']] } }
    let(:tmpdir) { Dir.mktmpdir }

    subject { described_class.new(build_dir: build_dir, rack_app: rack_app) }

    after do
      FileUtils.remove_entry_secure(tmpdir)
    end

    context 'with everything defined' do
      let(:build_dir) { tmpdir }
      let(:rack_app) { app }

      it do
        subject.routes.get '/'
        subject.build

        expect(Dir.children(tmpdir)).to eql(['index.html'])
      end
    end

    context 'with no routes' do
      let(:build_dir) { tmpdir }
      let(:rack_app) { app }

      it 'the build - with callbacks etc - still occurs' do
        subject.build

        expect(Dir.children(tmpdir)).to be_empty
      end
    end

    context 'when #build_dir is not set' do
      let(:build_dir) { nil }
      let(:rack_app) { app }

      it do
        subject.routes.get '/'

        expect {
          subject.build
        }.to raise_error(Parklife::BuildDirNotDefinedError)
      end
    end

    context 'when #rack_app is not set' do
      let(:build_dir) { tmpdir }
      let(:rack_app) { nil }

      it do
        subject.routes.get '/'

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
