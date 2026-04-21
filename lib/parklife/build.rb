# frozen_string_literal: true
require 'fileutils'
require 'yaml'

module Parklife
  class Build
    META_PATH = File.join('.parklife', 'build.yml')

    def self.from_dir(dir)
      return unless dir.exist?
      path = dir.join(META_PATH)
      return unless path.exist?
      data = YAML.safe_load(path.read)

      build = new(dir, nested_index: data.dig('config', 'nested_index'))
      build.paths.merge!(data['paths'])
      build
    end

    def self.path_for(path, media_type: nil, nested_index:)
      # Remove leading/trailing slashes.
      path = path.gsub(/^\/|\/$/, '')

      # The root is always expected to be an HTML page regardless of the
      # response's content type.
      return 'index.html' if path.empty?

      text_html = media_type.nil? || media_type == 'text/html'

      # Store a text/html response in an .html file.
      if text_html && !path.end_with?('.html')
        if nested_index
          path << '/index.html'
        else
          path << '.html'
        end
      end

      path
    end

    attr_reader :dir, :nested_index, :paths

    def initialize(dir, nested_index:)
      @dir = dir
      @nested_index = nested_index
      @paths = {}
    end

    def add(route, response)
      build_path = self.build_path(route, response)
      write(build_path, response.body)
      add_path_meta(route, response, build_path)
    end

    def build_path(route, response)
      self.class.path_for(
        route.path,
        media_type: response.media_type,
        nested_index: nested_index,
      )
    end

    def copy(src, route, response)
      build_path = self.build_path(route, response)

      dest = dir.join(build_path)
      dest.dirname.mkpath
      FileUtils.cp(src, dest)

      add_path_meta(route, response, build_path)
    end

    def etag(path)
      paths.dig(path, 'etag')
    end

    def get(route, response)
      dir.join(build_path(route, response))
    end

    def to_yaml
      YAML.dump({
        'config' => {
          'nested_index' => nested_index,
        },
        'paths' => paths,
      })
    end

    def write(path, content)
      file = dir.join(path)
      file.dirname.mkpath
      file.write(content, mode: 'wb')
    end

    def write_meta
      write(META_PATH, to_yaml)
    end

    private
      def add_path_meta(route, response, build_path)
        paths[route.path] = {
          'build_path' => build_path,
          'etag' => response['Etag'],
        }.compact
      end
  end
end
