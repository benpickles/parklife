# frozen_string_literal: true
require 'parklife/build'

RSpec.describe Parklife::Build do
  describe '.path_for' do
    [
      # Root paths are always saved as index.html.
      ['/', false, 'text/html', 'index.html'],
      ['/', true,  'text/html', 'index.html'],

      # Root paths with a non-HTML content type are treated the same.
      ['/', false, 'foo/bar', 'index.html'],
      ['/', true,  'foo/bar', 'index.html'],

      # When the content type is HTML paths are saved as HTML.
      ['/foo', false, 'text/html', 'foo.html'],
      ['/foo', true,  'text/html', 'foo/index.html'],

      # If the path already includes an HTML extension they're left unchanged.
      ['/foo.html', false, 'text/html', 'foo.html'],
      ['/foo.html', true,  'text/html', 'foo.html'],

      # text/html nested paths with nested_index=false.
      ['/a/b/c',      false, 'text/html', 'a/b/c.html'],
      ['/a/b/c.html', false, 'text/html', 'a/b/c.html'],
      ['/a/b/c/',     false, 'text/html', 'a/b/c.html'],

      # text/html nested paths with nested_index=true.
      ['/a/b/c',      true, 'text/html', 'a/b/c/index.html'],
      ['/a/b/c.html', true, 'text/html', 'a/b/c.html'],
      ['/a/b/c/',     true, 'text/html', 'a/b/c/index.html'],

      # Non-HTML nested paths.
      ['/a.json',     false, 'foo/bar', 'a.json'],
      ['/a/b/c',      false, 'foo/bar', 'a/b/c'],
      ['/a/b/c.json', false, 'foo/bar', 'a/b/c.json'],
      ['/a.json',     true,  'foo/bar', 'a.json'],
      ['/a/b/c',      true,  'foo/bar', 'a/b/c'],
      ['/a/b/c.json', true,  'foo/bar', 'a/b/c.json'],

      # If the response's content type is HTML save the file as HTML regardless
      # of the path's extension (this makes more sense with the next examples).
      ['/a/b/c.json', false, 'text/html', 'a/b/c.json.html'],
      ['/a/b/c.json', true,  'text/html', 'a/b/c.json/index.html'],

      # If the path can be interpreted as having an extension (.8) but the
      # response's content type is HTML then it's saved as HTML (the same as
      # above but makes sense this time).
      ['/dry-types/v1.8', false, 'text/html', 'dry-types/v1.8.html'],
      ['/dry-types/v1.8', true,  'text/html', 'dry-types/v1.8/index.html'],

      # Once again the path can be interpreted as having a .8 extension but
      # the response's content type isn't HTML so it's not saved as HTML.
      ['/dry-types/v1.8', false, 'foo/bar', 'dry-types/v1.8'],
      ['/dry-types/v1.8', true,  'foo/bar', 'dry-types/v1.8'],
    ].each do |(path, nested_index, media_type, expected)|
      settings = {
        path: path,
        nested_index: nested_index,
        media_type: media_type,
      }.map { |k, v| "#{k}=#{v.inspect}" }.join(' ')

      context "with #{settings}" do
        it do
          expect(
            described_class.path_for(
              path,
              media_type: media_type,
              nested_index: nested_index,
            )
          ).to eql(expected)
        end
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
