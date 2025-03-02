# frozen_string_literal: true
require 'fileutils'

module Parklife
  module Rails
    module ActiveStoragePlugin
      def self.call(app)
        app.before_build do
          ActiveStorage.collected_assets.clear
          ActiveStorage.collect_assets = true
        end

        app.after_build do
          ActiveStorage.collected_assets.each_value do |asset|
            build_path = File.join(app.config.build_dir, asset.url)
            FileUtils.mkdir_p(File.dirname(build_path))
            FileUtils.cp(asset.blob_path, build_path)
          end
        end
      end
    end
  end
end
