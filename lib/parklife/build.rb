# frozen_string_literal: true
module Parklife
  class Build
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

    attr_reader :dir, :nested_index

    def initialize(dir, nested_index:)
      @dir = dir
      @nested_index = nested_index
    end

    def add(route, response)
      build_path = self.class.path_for(
        route.path,
        media_type: response.media_type,
        nested_index: nested_index,
      )

      file = dir.join(build_path)
      file.dirname.mkpath
      file.write(response.body, mode: 'wb')
    end
  end
end
