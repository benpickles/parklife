require 'parklife/utils'

RSpec.describe Parklife::Utils do
  describe '#build_path_for' do
    subject { described_class.build_path_for(dir: dir, path: path, index: index) }

    context 'when index is true' do
      let(:index) { true }

      context 'with the root path' do
        let(:dir) { 'dist' }
        let(:path) { '/' }
        it { should eql('dist/index.html') }
      end

      context 'with an expanded directory' do
        let(:dir) { '/tmp/dist' }
        let(:path) { '/' }
        it { should eql('/tmp/dist/index.html') }
      end

      context 'with a nested path' do
        let(:dir) { 'dist' }
        let(:path) { '/bits/of/stuff' }
        it { should eql('dist/bits/of/stuff/index.html') }
      end

      context 'with a nested directory with a no preceding slash' do
        let(:dir) { 'dist' }
        let(:path) { 'bits/of/stuff' }
        it { should eql('dist/bits/of/stuff/index.html') }
      end

      context 'with an extension' do
        let(:dir) { 'dist' }
        let(:path) { '/some/path.json' }
        it { should eql('dist/some/path.json') }
      end
    end

    context 'when index is false' do
      let(:index) { false }

      context 'with the root path' do
        let(:dir) { 'dist' }
        let(:path) { '/' }
        it { should eql('dist/index.html') }
      end

      context 'with a nested path' do
        let(:dir) { 'dist' }
        let(:path) { '/bits/of/stuff' }
        it { should eql('dist/bits/of/stuff.html') }
      end

      context 'with an extension' do
        let(:dir) { 'dist' }
        let(:path) { '/some/path.json' }
        it { should eql('dist/some/path.json') }
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
