require 'thor'

module Parklife
  class CLI < Thor
    desc 'build', 'create a production build'
    def build
      application.build
    end

    desc 'routes', 'list all defined routes'
    def routes
      application.routes.to_a.sort.each do |route|
        puts route
      end
    end

    private
      def application
        @application ||= begin
          # Reach inside the consuming app's directory to load Parklife and
          # apply its config. It's only at this point that the
          # Parklife::Application is defined.
          load discover_Parkfile(Dir.pwd)

          Parklife.application.reporter = $stdout
          Parklife.application
        end
      end

      def discover_Parkfile(dir)
        File.expand_path('Parkfile', dir)
      end
  end
end
