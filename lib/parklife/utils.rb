module Parklife
  module Utils
    extend self

    def build_path_for(dir:, path:, index: true)
      path = path.gsub(/^\/|\/$/, '')

      if File.extname(path).empty?
        if index
          File.join(dir, path, 'index.html')
        else
          name = path.empty? ? 'index.html' : "#{path}.html"
          File.join(dir, name)
        end
      else
        File.join(dir, path)
      end
    end
  end
end
