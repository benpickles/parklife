# frozen_string_literal: true

module Parklife
  Error = Class.new(StandardError)
  BuildDirNotDefinedError = Class.new(Error)
  RackAppNotDefinedError = Class.new(Error)

  class HTTPError < Error
    def initialize(status, path)
      super %Q(#{status} response from path "#{path}")
    end
  end

  class ParkfileLoadError < Error
    def initialize(path)
      super %Q(Cannot load Parkfile "#{path}")
    end
  end

  class RailsNotDefinedError < Error
    def initialize(msg = 'Expected Rails to be defined, require config/environment before parklife')
      super
    end
  end
end
