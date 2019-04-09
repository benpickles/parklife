module Parklife
  module Utils
    extend self

    def build_path_for(dir:, path:)
      path = path.gsub(/^\/|\/$/, '')

      if File.extname(path).empty?
        File.join(dir, path, 'index.html')
      else
        File.join(dir, path)
      end
    end
  end
end
