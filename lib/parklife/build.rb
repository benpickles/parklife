# frozen_string_literal: true
require 'yaml'

module Parklife
  class Build
    META_PATH = File.join('.parklife', 'build.yml')

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
      build_path = self.class.path_for(
        route.path,
        media_type: response.media_type,
        nested_index: nested_index,
      )
      write(build_path, response.body)
      paths[route.path] = { 'build_path' => build_path }.compact
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
  end
end
