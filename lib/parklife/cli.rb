# frozen_string_literal: true

require 'parklife'
require 'thor'

module Parklife
  class CLI < Thor
    include Thor::Actions
    source_root File.expand_path('templates', __dir__)

    class_option :base, desc: 'Override config.base configured in the Parkfile'

    desc 'build', 'Create a production build'
    def build
      application.build
    end

    desc 'config', 'Output the full Parklife config'
    def config
      reporter = application.config.reporter

      shell.print_table([
        ['app', application.config.app.inspect],
        ['base', application.config.base.to_s],
        ['build_dir', application.config.build_dir],
        ['nested_index', application.config.nested_index],
        ['on_404', application.config.on_404.inspect],
        ['parklife/rails', defined?(::Parklife::Rails::Railtie) ? 'enabled' : '-'],
        ['parklife/sinatra', defined?(::Parklife::Sinatra) ? 'enabled' : '-'],
        ['reporter', reporter == $stdout ? '$stdout' : reporter],
      ])
    end

    desc 'get PATH', 'Fetch PATH from the app and output its contents'
    def get(path)
      puts application.crawler.get(path).body
    end

    desc 'init', 'Generate a starter Parkfile and friends'
    option :github_pages, desc: 'Generate a GitHub Actions workflow to deploy to GitHub Pages', type: :boolean
    option :rails, desc: 'Include some Rails-specific settings', type: :boolean
    option :sinatra, desc: 'Include some Sinatra-specific settings', type: :boolean
    def init
      template('Parkfile.erb', 'Parkfile')
      template('static_build.erb', 'bin/static-build')
      chmod('bin/static-build', 0755)
      copy_file('github_pages.yml', '.github/workflows/parklife.yml') if options[:github_pages]
    end

    desc 'routes', 'List all defined routes'
    def routes
      shell.print_table(
        application.routes.map { |route|
          [route.path, route.crawl ? "crawl=true" : nil]
        }
      )
    end

    map '--version' => :version
    desc 'version', 'Output the current version of Parklife'
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

          # Runtime overrides.
          app.config.base = options[:base] if options[:base]
        }
      end
  end
end
