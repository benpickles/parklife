require 'parklife/application'
require 'parklife/version'

module Parklife
  class Error < StandardError; end

  def self.application
    @application ||= Application.new
  end
end
