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

    map '--version' => :version
    desc 'version', 'output the current version of Parklife'
    def version
      puts Parklife::VERSION
    end

    private
      def application
        @application ||= Parklife.application.tap { |app|
          # Default output to stdout (can be overridden in the Parkfile).
          app.config.reporter = $stdout

          # Reach inside the consuming app's directory to apply its Parklife
          # config.
          app.load_Parkfile(File.join(Dir.pwd, 'Parkfile'))
        }
      end
  end
end
