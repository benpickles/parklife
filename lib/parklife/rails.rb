raise Parklife::RailsNotDefinedError unless defined?(Rails)

# Allow use of the consuming Rails application's route helpers from within the
# block when defining Parklife routes.
Parklife::RouteSet.include(Rails.application.routes.url_helpers)

Parklife.application.config.app = Rails.application
