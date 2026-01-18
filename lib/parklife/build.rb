# frozen_string_literal: true
module Parklife
  class Build
    def self.path_for(path, nested_index:)
      path = path.gsub(/^\/|\/$/, '')

      if File.extname(path).empty?
        if path.empty?
          'index.html'
        elsif nested_index
          File.join(path, 'index.html')
        else
          "#{path}.html"
        end
      else
        path
      end
    end

    attr_reader :dir, :nested_index

    def initialize(dir, nested_index:)
      @dir = dir
      @nested_index = nested_index
    end

    def add(route, response)
      build_path = self.class.path_for(route.path, nested_index: nested_index)

      file = dir.join(build_path)
      file.dirname.mkpath
      file.write(response.body, mode: 'wb')
    end
  end
end
