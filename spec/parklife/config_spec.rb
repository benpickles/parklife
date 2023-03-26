require 'parklife/config'

RSpec.describe Parklife::Config do
  describe '.new' do
    it do
      config = described_class.new
      expect(config.base).not_to be_nil
    end
  end

  describe '#base=' do
    let(:config) {
      described_class.new.tap { |c|
        c.base = value
      }
    }

    context 'with nil' do
      let(:value) { nil }

      it 'uses the defaults' do
        expect(config.base.to_s).to eql('http://example.com')
      end
    end

    context 'with a path only' do
      let(:value) { '/parklife' }

      it 'adds the default host/scheme' do
        expect(config.base.to_s).to eql('http://example.com/parklife')
      end
    end

    context 'with a URL' do
      let(:value) { 'https://foo.example.com/bar/' }

      it 'uses the passed host/scheme' do
        expect(config.base.to_s).to eql('https://foo.example.com/bar/')
      end
    end

    context 'with a pathless URL' do
      let(:value) { 'https://foo.example.com' }

      it 'uses the passed host/scheme' do
        expect(config.base.to_s).to eql('https://foo.example.com')
      end
    end

    context 'with a URI object' do
      let(:value) { URI.parse('https://foo.example.com/path') }

      it 'uses it' do
        expect(config.base).to be(value)
      end
    end

    context 'with a path-only URI object' do
      let(:value) { URI.parse('/path') }

      it 'adds the default host/scheme' do
        expect(config.base.to_s).to eql('http://example.com/path')
      end
    end
  end
end
