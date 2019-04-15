module Parklife
  Error = Class.new(StandardError)
  BuildDirNotDefinedError = Class.new(Error)
  RackAppNotDefinedError = Class.new(Error)

  class RailsNotDefinedError < Error
    def message
      'Expected Rails to be defined, require config/environment before parklife.'
    end
  end
end
