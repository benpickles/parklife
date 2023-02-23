require 'parklife/errors'

raise Parklife::RailsNotDefinedError unless defined?(Rails)

require 'parklife'

# Allow use of the consuming Rails application's route helpers from within the
# block when defining Parklife routes.
Parklife::RouteSet.include(Rails.application.routes.url_helpers)

Parklife.application.config.rack_app = Rails.application
