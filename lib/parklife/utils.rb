require 'nokogiri'

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

    def scan_for_links(html)
      doc = Nokogiri::HTML.parse(html)
      doc.css('a').each do |a|
        uri = URI.parse(a[:href])

        # Don't visit a URL that belongs to a different domain - for now this is
        # a guess that it's not an internal link but it also covers mailto/ftp
        # links.
        next if uri.host

        # Don't visit a path-less URL - this will be the case for a #fragment
        # for example.
        next if uri.path.nil? || uri.path.empty?

        yield uri.path
      end
    end
  end
end
