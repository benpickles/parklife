# frozen_string_literal: true
require 'parklife/build'

RSpec.describe Parklife::Build do
  describe '.path_for' do
    subject { described_class.path_for(path, nested_index: nested_index) }

    context 'when nested_index=true' do
      let(:nested_index) { true }

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

    context 'when nested_index=false' do
      let(:nested_index) { false }

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

  describe '#add' do
    let(:build) {
      described_class.new(
        Pathname.new(build_dir),
        nested_index: nested_index,
      )
    }
    let(:tmpdir) { Dir.mktmpdir }

    def add(path, body)
      build.add(
        Parklife::Route.new(path, crawl: false),
        Rack::MockResponse.new(200, {}, body)
      )
    end

    def build_files
      @build_files ||= Dir.glob('**/*', base: tmpdir).select { |path|
        File.file?(File.join(tmpdir, path))
      }
    end

    context 'with a nested directory that does not exist' do
      let(:build_dir) { File.join(tmpdir, 'nested') }
      let(:nested_index) { true }

      it 'creates the required directories' do
        add('foo/bar/baz', '1')
        add('foo/bar', '2')
        add('foo', '3')

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
        add('foo', 'foo content')
        add('bar', 'bar content')

        expect(build_files).to contain_exactly('bar.html', 'foo.html')

        file_path = File.join(tmpdir, 'bar.html')

        expect(File.read(file_path)).to eql('bar content')
      end
    end
  end
end
