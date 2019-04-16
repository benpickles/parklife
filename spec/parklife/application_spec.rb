require 'parklife/application'
require 'tmpdir'

RSpec.describe Parklife::Application do
  describe '#build' do
    let(:endpoint_200) { Proc.new { |env| [200, { 'Content-Type' => 'text/html' }, ['200']] } }
    let(:endpoint_302) { Proc.new { |env| [302, { 'Content-Type' => 'text/html', 'Location' => 'http://example.com/' }, ['302']] } }
    let(:endpoint_500) { Proc.new { |env| [500, { 'Content-Type' => 'text/html' }, ['500']] } }
    let(:tmpdir) { Dir.mktmpdir }

    subject { described_class.new(build_dir: build_dir, rack_app: rack_app) }

    after do
      FileUtils.remove_entry_secure(tmpdir)
    end

    context 'with everything defined' do
      let(:build_dir) { tmpdir }
      let(:rack_app) { endpoint_200 }

      it do
        subject.routes.get '/'
        subject.build

        expect(Dir.children(tmpdir)).to eql(['index.html'])

        index = File.join(tmpdir, 'index.html')

        expect(File.read(index)).to eql('200')
      end
    end

    context 'when an endpoint responds with a redirect' do
      let(:build_dir) { tmpdir }
      let(:rack_app) { endpoint_302 }

      it do
        subject.routes.get('/redirect-me')

        expect {
          subject.build
        }.to raise_error(Parklife::HTTPError, '302 response from path "/redirect-me"')
      end
    end

    context 'when an endpoint does not respond with a 200' do
      let(:build_dir) { tmpdir }
      let(:rack_app) { endpoint_500 }

      it do
        subject.routes.get('/everything-is-a-500')

        expect {
          subject.build
        }.to raise_error(Parklife::HTTPError, '500 response from path "/everything-is-a-500"')
      end
    end

    context 'with callbacks' do
      let(:build_dir) { tmpdir }
      let(:rack_app) { endpoint_200 }

      it 'they are called in the correct order' do
        callbacks = []

        subject.after_build { callbacks << 2 }
        subject.before_build { callbacks << 1 }

        subject.build

        expect(callbacks).to eql([1, 2])
      end
    end

    context 'with no routes' do
      let(:build_dir) { tmpdir }
      let(:rack_app) { endpoint_200 }

      it 'the build - with callbacks etc - still occurs' do
        subject.build

        expect(Dir.children(tmpdir)).to be_empty
      end
    end

    context 'when #build_dir is not set' do
      let(:build_dir) { nil }
      let(:rack_app) { endpoint_200 }

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
