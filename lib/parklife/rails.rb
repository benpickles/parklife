raise Parklife::RailsNotDefinedError unless defined?(Rails)

Parklife.application.config.app = Rails.application

# Allow use of the Rails application's route helpers when defining Parklife
# routes in the block form.
Parklife.application.routes.singleton_class.include(Rails.application.routes.url_helpers)
