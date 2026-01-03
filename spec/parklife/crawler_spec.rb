require 'parklife/config'
require 'parklife/crawler'
require 'parklife/route_set'
require 'tmpdir'

RSpec.describe Parklife::Crawler do
  let(:build_dir) { Dir.mktmpdir }
  let(:config) {
    Parklife::Config.new.tap { |config|
      config.app = app
      config.build_dir = build_dir
    }
  }
  let(:endpoint_200) {
    Proc.new { |env|
      request = Rack::Request.new(env)
      extname = File.extname(request.path)
      content_type = Rack::Mime.mime_type(extname, 'text/html')
      [200, { 'content-type' => content_type }, ['200']]
    }
  }
  let(:route_set) { Parklife::RouteSet.new }

  subject { described_class.new(config, route_set) }

  after do
    FileUtils.remove_entry_secure(build_dir)
  end

  context 'with standard config' do
    let(:app) { endpoint_200 }

    it do
      route_set.get '/'
      route_set.get '/foo'

      subject.start

      expect(build_files).to match_array(['foo/index.html', 'index.html'])

      index = File.join(build_dir, 'index.html')

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

      expect(build_files).to eql(['index.html'])

      index = File.join(build_dir, 'index.html')

      expect(File.read(index)).to eql('https,foo.example.com')
    end
  end

  context 'with no routes' do
    let(:app) { endpoint_200 }

    it 'the build still occurs' do
      subject.start

      expect(build_files).to be_empty
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

      foo = File.join(build_dir, 'foo/index.html')

      expect(File.read(foo)).to eql('<a href="/subdir/bar">/bar</a>')
    end
  end

  context 'when a custom responder is registered for a status code' do
    let(:app) {
      Proc.new {
        [418, {}, ['ignored']]
      }
    }

    let(:teapot) {
      Class.new(Parklife::Responder::Base) do
        def call(route, response)
          response.body = ["I'm a teapot"]
          crawler.build.add(route, response)
        end
      end
    }

    around do |example|
      Parklife::Crawler::RESPONDERS[418] = teapot
      example.run
      Parklife::Crawler::RESPONDERS.delete(418)
    end

    it 'is used' do
      route_set.get '/'

      subject.start

      expect(build_files).to contain_exactly('index.html')

      index = File.join(build_dir, 'index.html')

      expect(File.read(index)).to eql("I'm a teapot")
    end
  end
end
