require 'parklife/application'
require 'tmpdir'

RSpec.describe Parklife::Application do
  describe '#build' do
    let(:endpoint_200) { Proc.new { |env| [200, {}, ['200']] } }
    let(:endpoint_302) { Proc.new { |env| [302, { 'Location' => 'http://example.com/' }, ['302']] } }
    let(:endpoint_500) { Proc.new { |env| [500, {}, ['500']] } }
    let(:tmpdir) { Dir.mktmpdir }

    subject {
      described_class.new.tap { |application|
        application.configure do |config|
          config.app = app
          config.build_dir = build_dir
        end
      }
    }

    context 'when config.build_dir is not set' do
      let(:app) { endpoint_200 }
      let(:build_dir) { nil }

      it do
        expect {
          subject.build
        }.to raise_error(Parklife::BuildDirNotDefinedError)
      end
    end

    context 'when config.app is not set' do
      let(:app) { nil }
      let(:build_dir) { tmpdir }

      it do
        expect {
          subject.build
        }.to raise_error(Parklife::RackAppNotDefinedError)
      end
    end
  end

  describe '#load_Parkfile' do
    let(:application) { described_class.new }
    let(:parkfile_path) { File.join(tmpdir, 'Parkfile') }
    let(:tmpdir) { Dir.mktmpdir }

    context 'when the Parkfile is present' do
      around do |example|
        old_application = Parklife.application
        Parklife.instance_variable_set(:@application, application)
        example.run
        Parklife.instance_variable_set(:@application, old_application)
      end

      before do
        File.write(
          parkfile_path,
          <<~RUBY
            Parklife.application.configure do |config|
              config.on_404 = :warn
            end

            Parklife.application.routes do
              get '/parkfile-exists'
            end
          RUBY
        )
      end

      it 'applies its configuration' do
        route = Parklife::Route.new('/parkfile-exists', crawl: false)

        expect { application.load_Parkfile(parkfile_path) }
          .to change { application.config.on_404 }.from(:error).to(:warn)
          .and change { application.routes.include?(route) }.from(false).to(true)
      end
    end

    context 'when the Parkfile does not exist' do
      it do
        expect {
          application.load_Parkfile(parkfile_path)
        }.to raise_error(Parklife::ParkfileLoadError)
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
