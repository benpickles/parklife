# frozen_string_literal: true

require 'fileutils'
require 'nokogiri'

module Parklife
  module Utils
    extend self

    def host_with_port(uri)
      default_port = uri.scheme == 'https' ? 443 : 80
      uri.port == default_port ? uri.host : "#{uri.host}:#{uri.port}"
    end

    def scan_for_links(html)
      doc = Nokogiri::HTML.parse(html)
      doc.css('a[href]').each do |a|
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
