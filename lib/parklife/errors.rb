module Parklife
  Error = Class.new(StandardError)
  BuildDirNotDefinedError = Class.new(Error)
  RackAppNotDefinedError = Class.new(Error)
end
