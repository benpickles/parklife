require 'parklife/utils'

RSpec.describe Parklife::Utils do
  describe '#build_path_for' do
    subject { described_class.build_path_for(path, index: index) }

    context 'when index is true' do
      let(:index) { true }

      context 'with the root path' do
        let(:path) { '/' }
        it { should eql('index.html') }
      end

      context 'with a nested path' do
        let(:path) { '/bits/of/stuff' }
        it { should eql('bits/of/stuff/index.html') }
      end

      context 'with a nested path with trailing slash' do
        let(:path) { '/bits/of/stuff/' }
        it { should eql('bits/of/stuff/index.html') }
      end

      context 'with a nested directory with a no preceding slash' do
        let(:path) { 'bits/of/stuff' }
        it { should eql('bits/of/stuff/index.html') }
      end

      context 'with an extension' do
        let(:path) { '/some/path.json' }
        it { should eql('some/path.json') }
      end
    end

    context 'when index is false' do
      let(:index) { false }

      context 'with the root path' do
        let(:path) { '/' }
        it { should eql('index.html') }
      end

      context 'with a nested path' do
        let(:path) { '/bits/of/stuff' }
        it { should eql('bits/of/stuff.html') }
      end

      context 'with a nested path with trailing slash' do
        let(:path) { '/bits/of/stuff/' }
        it { should eql('bits/of/stuff.html') }
      end

      context 'with an extension' do
        let(:path) { '/some/path.json' }
        it { should eql('some/path.json') }
      end

      context 'with an extension at the root' do
        let(:path) { '/index.json' }
        it { should eql('index.json') }
      end
    end
  end

  describe '#save_page' do
    let(:config) {
      Parklife::Config.new.tap { |c|
        c.build_dir = build_dir
        c.nested_index = nested_index
      }
    }
    let(:tmpdir) { Dir.mktmpdir }

    def build_files
      @build_files ||= Dir.glob('**/*', base: tmpdir).select { |path|
        File.file?(File.join(tmpdir, path))
      }
    end

    context 'with a nested directory that does not exist' do
      let(:build_dir) { File.join(tmpdir, 'nested') }
      let(:nested_index) { true }

      it 'creates the required directories' do
        described_class.save_page('foo/bar/baz', '1', config)
        described_class.save_page('foo/bar', '2', config)
        described_class.save_page('foo', '3', config)

        expect(build_files).to match_array([
          'nested/foo/index.html',
          'nested/foo/bar/index.html',
          'nested/foo/bar/baz/index.html',
        ])
      end
    end

    context 'when the directory exists and taking config.nested_index into account' do
      let(:build_dir) { tmpdir }
      let(:nested_index) { false }

      it do
        described_class.save_page('foo', 'foo content', config)
        described_class.save_page('bar', 'bar content', config)

        expect(build_files).to eql(['bar.html', 'foo.html'])

        file_path = File.join(tmpdir, 'bar.html')

        expect(File.read(file_path)).to eql('bar content')
      end
    end
  end

  describe '#scan_for_links' do
    let(:html) {
      <<~HTML
        ✅ <a href="/foo">foo</a>
        ❌ <a href="https://www.example.com">external</a>
        ❌ <a href="#fragment">fragment</a>
        ✅ <a href="/bar">bar</a>
        ❌ <a href="mailto:bob@example.com">mailto</a>
        ❌ <a href="">empty</a>
        ✅ <a href="/baz">baz</a>
        ❌ <a href="ftp://example.com/foo/bar">ftp</a>
      HTML
    }

    it do
      expect { |block|
        described_class.scan_for_links(html, &block)
      }.to yield_successive_args(
        '/foo',
        '/bar',
        '/baz'
      )
    end
  end
end
