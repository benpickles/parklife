# frozen_string_literal: true

require 'fileutils'
require 'nokogiri'

module Parklife
  module Utils
    extend self

    def build_path_for(path, index: true)
      path = path.gsub(/^\/|\/$/, '')

      if File.extname(path).empty?
        if path.empty?
          'index.html'
        elsif index
          File.join(path, 'index.html')
        else
          "#{path}.html"
        end
      else
        path
      end
    end

    def host_with_port(uri)
      default_port = uri.scheme == 'https' ? 443 : 80
      uri.port == default_port ? uri.host : "#{uri.host}:#{uri.port}"
    end

    def save_page(path, content, config)
      build_path = File.join(
        config.build_dir,
        build_path_for(path, index: config.nested_index)
      )
      FileUtils.mkdir_p(File.dirname(build_path))
      File.write(build_path, content, mode: 'wb')
    end

    def scan_for_links(html)
      doc = Nokogiri::HTML.parse(html)

      # In this very exciting exercise we'll go through a list of elements to collect a list of candidate
      # urls that *maybe* we'll want to crawl.
      urls = doc.css('a').map { |v| v[:href] }
      urls.concat(doc.css('img').map { |v| v[:src] })

      # Source elements come in two flavors, for images the srcset attribute is used, for audio / video the src is used
      urls.concat(doc.css('source').map { |v| [v[:srcset], v[:src]].compact.reject(&:empty?).first })

      urls.each do |url|
        uri = URI.parse(url)

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
