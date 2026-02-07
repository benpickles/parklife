require 'parklife/utils'

RSpec.describe Parklife::Utils do
  describe '#host_with_port' do
    context 'with a' do
      subject { described_class.host_with_port(uri) }

      context 'with the standard http port' do
        let(:uri) { URI.parse('http://localhost:80') }
        it { should eql('localhost') }
      end

      context 'with the standard https port' do
        let(:uri) { URI.parse('https://localhost:443') }
        it { should eql('localhost') }
      end

      context 'with a non-standard port' do
        let(:uri) { URI.parse('http://localhost:3000') }
        it { should eql('localhost:3000') }
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
        ❌ <a>no-href</a>
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
