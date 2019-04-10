require 'fileutils'
require 'parklife'
require 'rake'

# Allow use of the consuming Rails application's route helpers from within the
# block when defining Parklife routes.
Parklife::RouteSet.include(Rails.application.routes.url_helpers)

Parklife.application.build_dir = Rails.root.join('build')
Parklife.application.rack_app = Rails.application

Parklife.application.before_build do |app|
  rake_app = Rake.application
  rake_app.init
  rake_app.load_rakefile
  rake_app['assets:precompile'].invoke

  FileUtils.cp_r(Rails.root.join('public/.'), app.build_dir)
end
