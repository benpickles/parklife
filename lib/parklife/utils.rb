module Parklife
  module Utils
    extend self

    def build_path(build_dir, route)
      path = route.gsub(/^\/|\/$/, '')
      File.join(build_dir, path, 'index.html')
    end
  end
end
