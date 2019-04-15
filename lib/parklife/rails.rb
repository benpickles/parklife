raise Parklife::RailsNotDefinedError if defined?(Rails).nil?

require 'fileutils'
require 'parklife'

# Allow use of the consuming Rails application's route helpers from within the
# block when defining Parklife routes.
Parklife::RouteSet.include(Rails.application.routes.url_helpers)

Parklife.application.build_dir = Rails.root.join('build')
Parklife.application.rack_app = Rails.application

Parklife.application.before_build do |app|
  Rails.application.load_tasks

  if Rake::Task.task_defined?('assets:precompile')
    Rake::Task['assets:precompile'].invoke
  end

  FileUtils.cp_r(Rails.root.join('public/.'), app.build_dir)
end
