require 'parklife/config'
require 'parklife/crawler'
require 'parklife/route_set'
require 'tmpdir'

RSpec.describe Parklife::Crawler do
  let(:config) {
    Parklife::Config.new.tap { |config|
      config.build_dir = tmpdir
      config.rack_app = rack_app
    }
  }
  let(:endpoint_200) { Proc.new { |env| [200, {}, ['200']] } }
  let(:endpoint_302) { Proc.new { |env| [302, { 'Location' => 'http://example.com/' }, ['302']] } }
  let(:endpoint_500) { Proc.new { |env| [500, {}, ['500']] } }
  let(:route_set) { Parklife::RouteSet.new }
  let(:tmpdir) { Dir.mktmpdir }

  subject { described_class.new(config, route_set) }

  after do
    FileUtils.remove_entry_secure(tmpdir)
  end

  context 'with standard config' do
    let(:rack_app) { endpoint_200 }

    it do
      route_set.get '/'
      route_set.get '/foo'

      subject.start

      files = Dir.glob('**/*', base: tmpdir)

      expect(files).to match_array(['foo', 'foo/index.html', 'index.html'])

      index = File.join(tmpdir, 'index.html')

      expect(File.read(index)).to eql('200')
    end
  end

  context 'when config.nested_index=false' do
    let(:rack_app) { endpoint_200 }

    it do
      config.nested_index = false

      route_set.get '/'
      route_set.get '/foo'
      route_set.get '/foo.xml'
      route_set.get '/nested/foo'

      subject.start

      files = Dir.glob('**/*', base: tmpdir)

      expect(files).to match_array([
        'foo.html',
        'foo.xml',
        'index.html',
        'nested',
        'nested/foo.html',
      ])
    end
  end

  context 'when config.base is defined' do
    let(:rack_app) { Proc.new { |env| [200, {}, [env['rack.url_scheme'], ',', env['HTTP_HOST']]] } }

    it do
      config.base = 'https://foo.example.com'

      route_set.get '/'

      subject.start

      expect(Dir.children(tmpdir)).to eql(['index.html'])

      index = File.join(tmpdir, 'index.html')

      expect(File.read(index)).to eql('https,foo.example.com')
    end
  end

  context 'when an endpoint responds with a redirect' do
    let(:rack_app) { endpoint_302 }

    it do
      route_set.get('/redirect-me')

      expect {
        subject.start
      }.to raise_error(Parklife::HTTPError, '302 response from path "/redirect-me"')
    end
  end

  context 'when an endpoint does not respond with a 200' do
    let(:rack_app) { endpoint_500 }

    it do
      route_set.get('/everything-is-a-500')

      expect {
        subject.start
      }.to raise_error(Parklife::HTTPError, '500 response from path "/everything-is-a-500"')
    end
  end

  context 'with no routes' do
    let(:rack_app) { endpoint_200 }

    it 'the build still occurs' do
      subject.start

      expect(Dir.children(tmpdir)).to be_empty
    end
  end

  context 'with crawl=true' do
    let(:rack_app) {
      Proc.new { |env|
        html = case env['PATH_INFO']
        when '/'
          '<a href="/foo">foo</a>, <a href="/bar">bar</a>, <a href="/baz">baz</a>'
        when '/foo'
          '<a href="/bar">bar</a>'
        when '/bar'
          '<a href="/baz">baz</a>, <a href="/foo">foo</a>'
        when '/baz'
          '<a href="/other">other</a>'
        when '/other'
          '<a href="https://www.wikipedia.org">Wikipedia</a>'
        else
          '200'
        end

        [200, {}, [html]]
      }
    }

    it do
      route_set.get('/', crawl: true)
      route_set.get('/another')

      subject.start

      files = Dir.glob('**/*', base: tmpdir)

      expect(files).to match_array([
        'another',
        'another/index.html',
        'bar',
        'bar/index.html',
        'baz',
        'baz/index.html',
        'foo',
        'foo/index.html',
        'index.html',
        'other',
        'other/index.html',
      ])
    end
  end
end
