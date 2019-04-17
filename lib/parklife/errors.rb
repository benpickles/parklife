module Parklife
  Error = Class.new(StandardError)
  BuildDirNotDefinedError = Class.new(Error)
  RackAppNotDefinedError = Class.new(Error)

  class HTTPError < Error
    def initialize(path:, status:)
      @path = path
      @status = status
    end

    def message
      %Q(#{status} response from path "#{path}")
    end

    private
      attr_reader :path, :status
  end

  class RailsNotDefinedError < Error
    def message
      'Expected Rails to be defined, require config/environment before parklife.'
    end
  end
end
