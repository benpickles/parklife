require 'parklife/errors'

raise Parklife::RailsNotDefinedError if defined?(Rails).nil?

require 'parklife'

# Allow use of the consuming Rails application's route helpers from within the
# block when defining Parklife routes.
Parklife::RouteSet.include(Rails.application.routes.url_helpers)

Parklife.application.build_dir = Rails.root.join('build')
Parklife.application.rack_app = Rails.application
