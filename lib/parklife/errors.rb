module Parklife
  Error = Class.new(StandardError)
  BuildDirNotDefinedError = Class.new(Error)
  RackAppNotDefinedError = Class.new(Error)

  class HTTPError < Error
    def initialize(session)
      @session = session
    end

    def message
      %Q(#{session.status_code} response from path "#{session.current_path}")
    end

    private
      attr_reader :session
  end

  class RailsNotDefinedError < Error
    def message
      'Expected Rails to be defined, require config/environment before parklife.'
    end
  end
end
