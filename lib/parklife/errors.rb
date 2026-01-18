# frozen_string_literal: true

module Parklife
  Error = Class.new(StandardError)
  RackAppNotDefinedError = Class.new(Error)

  class HTTPError < Error
    def initialize(status, path)
      super %Q(#{status} response from path "#{path}")
    end
  end

  class HTTPRedirectError < Error
    def initialize(status, from, to)
      super %Q(#{status} redirect from "#{from}" to "#{to}")
    end
  end

  class ParkfileLoadError < Error
    def initialize(path)
      super %Q(Cannot load Parkfile "#{path}")
    end
  end
end
