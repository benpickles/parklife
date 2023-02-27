module Parklife
  Error = Class.new(StandardError)
  BuildDirNotDefinedError = Class.new(Error)
  RackAppNotDefinedError = Class.new(Error)

  class HTTPError < Error
    def initialize(status, path)
      @status = status
      @path = path
    end

    def message
      %Q(#{@status} response from path "#{@path}")
    end
  end

  class RailsNotDefinedError < Error
    def message
      'Expected Rails to be defined, require config/environment before parklife.'
    end
  end
end
