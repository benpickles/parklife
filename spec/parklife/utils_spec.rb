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
end
