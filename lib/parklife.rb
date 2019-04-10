require 'parklife/application'
require 'parklife/version'

module Parklife
  def self.application
    @application ||= Application.new
  end
end
