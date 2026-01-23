require 'parklife/config'
require 'parklife/crawler'
require 'parklife/route_set'
require 'tmpdir'

RSpec.describe Parklife::Crawler do
  let(:config) {
    Parklife::Config.new.tap { |config|
      config.app = app
      config.build_dir = tmpdir
    }
  }
  let(:endpoint_200) { Proc.new { [200, {}, ['200']] } }
  let(:endpoint_301) { Proc.new { [301, { 'Location' => 'https://foo.example.org/bar' }, ['301']] } }
  let(:endpoint_302) { Proc.new { [302, { 'Location' => 'https://foo.example.org/bar' }, ['302']] } }
  let(:endpoint_500) { Proc.new { [500, {}, ['500']] } }
  let(:route_set) { Parklife::RouteSet.new }
  let(:tmpdir) { Dir.mktmpdir }

  subject { described_class.new(config, route_set) }

  after do
    FileUtils.remove_entry_secure(tmpdir)
  end

  def build_files
    @build_files ||= Dir.glob('**/*', base: tmpdir).select { |path|
      File.file?(File.join(tmpdir, path))
    }
  end

  context 'with standard config' do
    let(:app) { endpoint_200 }

    it do
      route_set.get '/'
      route_set.get '/foo'

      subject.start

      expect(build_files).to match_array(['foo/index.html', 'index.html'])

      index = File.join(tmpdir, 'index.html')

      expect(File.read(index)).to eql('200')
    end
  end

  context 'when config.nested_index=false' do
    let(:app) { endpoint_200 }

    it do
      config.nested_index = false

      route_set.get '/'
      route_set.get '/foo'
      route_set.get '/foo.xml'
      route_set.get '/nested/foo'

      subject.start

      expect(build_files).to match_array([
        'foo.html',
        'foo.xml',
        'index.html',
        'nested/foo.html',
      ])
    end
  end

  context 'when config.base is defined' do
    let(:app) { Proc.new { |env| [200, {}, [env['rack.url_scheme'], ',', env['HTTP_HOST']]] } }

    it do
      config.base = 'https://foo.example.com'

      route_set.get '/'

      subject.start

      expect(Dir.children(tmpdir)).to eql(['index.html'])

      index = File.join(tmpdir, 'index.html')

      expect(File.read(index)).to eql('https,foo.example.com')
    end
  end

  context 'when an endpoint responds with a 301 redirect' do
    let(:app) { endpoint_301 }

    it do
      route_set.get('/redirect-me')

      expect {
        subject.start
      }.to raise_error(Parklife::HTTPRedirectError, '301 redirect from "http://example.com/redirect-me" to "https://foo.example.org/bar"')
    end
  end

  context 'when an endpoint responds with a 302 redirect' do
    let(:app) { endpoint_302 }

    it do
      route_set.get('/redirect-me')

      expect {
        subject.start
      }.to raise_error(Parklife::HTTPRedirectError, '302 redirect from "http://example.com/redirect-me" to "https://foo.example.org/bar"')
    end
  end

  context 'when an endpoint does not respond with a 200' do
    let(:app) { endpoint_500 }

    it do
      route_set.get('/everything-is-a-500')

      expect {
        subject.start
      }.to raise_error(Parklife::HTTPError, '500 response from path "/everything-is-a-500"')
    end
  end

  context 'with no routes' do
    let(:app) { endpoint_200 }

    it 'the build still occurs' do
      subject.start

      expect(Dir.children(tmpdir)).to be_empty
    end
  end

  context 'with crawl=true' do
    let(:app) {
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

      expect(build_files).to match_array([
        'another/index.html',
        'bar/index.html',
        'baz/index.html',
        'foo/index.html',
        'index.html',
        'other/index.html',
      ])
    end
  end

  context 'when crawling an app mounted at a subdirectory' do
    let(:app) {
      Proc.new { |env|
        request = Rack::Request.new(env)
        link = -> (path) {
          full_path = File.join(request.script_name, path)
          %(<a href="#{full_path}">#{path}</a>)
        }

        html = case env['PATH_INFO']
        when '/'
          [
            link.('/foo'),
            link.('/bar'),
            link.('/baz'),
          ].join(' ')
        when '/foo'
          link.('/bar')
        else
          '200'
        end

        [200, {}, [html]]
      }
    }

    it 'saves responses to the correct (non subdirectory) path but links include the subdirectory' do
      config.base = '/subdir'

      route_set.get('/', crawl: true)

      subject.start

      expect(build_files).to match_array([
        'index.html',
        'foo/index.html',
        'bar/index.html',
        'baz/index.html',
      ])

      foo = File.join(tmpdir, 'foo/index.html')

      expect(File.read(foo)).to eql('<a href="/subdir/bar">/bar</a>')
    end
  end

  context 'when encountering a 404 response' do
    let(:app) { Proc.new { [404, {}, ['404']] } }

    before do
      config.on_404 = on_404
      route_set.get '/404'
    end

    around do |example|
      old_stderr, $stderr = $stderr, StringIO.new
      example.run
      $stderr = old_stderr
    end

    context 'with on_404=:error setting' do
      let(:on_404) { :error }

      it do
        expect {
          subject.start
        }.to raise_error(Parklife::HTTPError, '404 response from path "/404"')
      end
    end

    context 'with on_404=:warn setting' do
      let(:on_404) { :warn }

      it 'skips the response and prints a warning to stderr' do
        subject.start
        expect($stderr.string.chomp).to eql('404 response from path "/404"')
        expect(build_files).to be_empty
      end
    end

    context 'with on_404=:skip setting' do
      let(:on_404) { :skip }

      it 'skips the response and does not output anything to stderr' do
        subject.start
        expect($stderr.string).to be_empty
        expect(build_files).to be_empty
      end
    end
  end
end
