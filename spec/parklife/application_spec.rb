require 'digest'
require 'tmpdir'
require 'parklife/application'

RSpec.describe Parklife::Application do
  describe '#build' do
    subject(:application) { described_class.new }

    let(:app) { Proc.new { [200, {}, ['200']] } }
    let(:config) { application.config }
    let(:tmpdir) { Dir.mktmpdir }

    before do
      config.app = app
      config.build_dir = build_dir
    end

    context 'when config.build_dir does not exist' do
      let(:build_dir) { File.join(tmpdir, 'foo') }

      it 'it is created' do
        expect {
          subject.build
        }.to change {
          Dir.exist?(build_dir)
        }.to(true)
      end
    end

    context 'when config.build_dir already exists' do
      let(:build_dir) { tmpdir }

      it 'remains but its contents are removed' do
        subject.config.skip_build_meta = true

        FileUtils.touch(File.join(tmpdir, 'foo.html'))
        FileUtils.mkdir_p(File.join(tmpdir, 'nested', 'directory'))
        FileUtils.touch(File.join(tmpdir, 'nested', 'directory', 'bar.html'))
        FileUtils.touch(File.join(tmpdir, '.hidden'))

        expect {
          subject.build
        }.not_to change {
          File.stat(tmpdir).ino
        }

        expect(build_files).to be_empty
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

    context 'with callbacks' do
      let(:build_dir) { tmpdir }

      it 'they are called in the correct order' do
        stuff = []

        subject.after_build { stuff << 2 }
        subject.before_build { stuff << 1 }

        subject.build

        expect(stuff).to eql([1, 2])
      end
    end

    context 'when build_dir and cache_dir are the same (i.e. the previous build is used as the cache)' do
      let(:app) {
        Proc.new { |env|
          html = case env['PATH_INFO']
          when '/'
            '<a href="/foo">foo</a>'
          when '/foo'
            foo_body
          else
            '200'
          end

          etag = Digest::MD5.hexdigest(html)
          headers = { 'etag' => etag }

          if env['HTTP_IF_NONE_MATCH'] == etag
            [304, headers, ['']]
          else
            [200, headers, [html]]
          end
        }
      }
      let(:build_dir) { 'build' }
      let(:cache_dir) { build_dir }
      let(:foo_body) { 'foo' }

      around do |example|
        Dir.chdir(tmpdir) do
          config.cache_dir = cache_dir
          subject.routes.root crawl: true
          example.run
        end
      end

      context 'and build_dir/cache_dir exist' do
        before do
          config.build_dir.mkpath
        end

        context 'and includes build metadata' do
          before do
            build = Parklife::Build.new(
              config.build_dir,
              nested_index: config.nested_index,
            )
            build.add(
              Parklife::Route.new('/foo', crawl: false),
              Rack::MockResponse.new(
                200,
                { 'etag' => Digest::MD5.hexdigest(foo_body) },
                '<a href="/bar">bar</a>' # Link to another page in the cache.
              )

            )
            build.write_meta
          end

          context 'and the tmp cache directory does not already exist' do
            it 'the previous build is moved to a tmp directory and used as the cache_dir' do
              subject.build

              expect(build_files).to contain_exactly(
                '.parklife/build.yml',
                'bar/index.html', # Page linked from cache.
                'foo/index.html',
                'index.html',
              )
            end
          end

          context 'but the tmp cache directory already exists' do
            before do
              cache_tmpdir = Parklife::Config::CACHE_TMPDIR
              FileUtils.mkpath(cache_tmpdir)
              FileUtils.touch(File.join(cache_tmpdir, 'delete-me.html'))
            end

            it 'the tmp cache directory is replaced by the existing build/cache and used as the cache_dir' do
              subject.build

              expect(build_files).to contain_exactly(
                '.parklife/build.yml',
                'bar/index.html', # Page linked from cache.
                'foo/index.html',
                'index.html',
              )
            end
          end

          context 'when build_dir/cache_dir point to the same directory but are formatted differently' do
            let(:cache_dir) { './build/' }

            it 'recognises that the paths match and works as expected' do
              subject.build

              expect(build_files).to contain_exactly(
                '.parklife/build.yml',
                'bar/index.html', # Page linked from cache.
                'foo/index.html',
                'index.html',
              )
            end
          end
        end

        context 'but does not include build metadata' do
          it 'builds without the cache' do
            subject.build

            expect(build_files).to contain_exactly(
              '.parklife/build.yml',
              'foo/index.html',
              'index.html',
            )
          end
        end
      end

      context 'but build_dir/cache_dir does not exist' do
        it 'cache_dir is unset' do
          subject.build

          expect(subject.config.cache_dir).to be_nil
        end
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
