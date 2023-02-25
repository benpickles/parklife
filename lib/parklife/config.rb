require 'stringio'

module Parklife
  class Config
    attr_accessor :app, :base, :build_dir, :nested_index, :on_404, :reporter

    def initialize
      self.build_dir = 'build'
      self.nested_index = true
      self.on_404 = :error
      self.reporter = StringIO.new
    end
  end
end
