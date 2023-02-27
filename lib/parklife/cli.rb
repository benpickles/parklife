require 'parklife'
require 'thor'

module Parklife
  class CLI < Thor
    desc 'build', 'create a production build'
    option :base, desc: 'set config.base at build-time - overrides the Parkfile setting'
    def build
      # Parkfile config overrides.
      application.config.base = options[:base] if options[:base]

      application.build
    end

    desc 'routes', 'list all defined routes'
    def routes
      application.routes.each do |route|
        print route.path
        print "\tcrawl=true" if route.crawl
        puts
      end
    end

    private
      def application
        @application ||= begin
          # Reach inside the consuming app's directory to load Parklife and
          # apply its config. It's only at this point that the
          # Parklife::Application is defined.
          load discover_Parkfile(Dir.pwd)

          Parklife.application.config.reporter = $stdout
          Parklife.application
        end
      end

      def discover_Parkfile(dir)
        File.expand_path('Parkfile', dir)
      end
  end
end
