require 'stringio'

module Parklife
  class Config
    attr_accessor :base, :build_dir, :nested_index, :rack_app, :reporter

    def initialize
      self.nested_index = true
      self.reporter = StringIO.new
    end
  end
end
