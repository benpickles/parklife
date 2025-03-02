# frozen_string_literal: true
require_relative '../active_storage/service/parklife_service'

module Parklife
  module ActiveStorage
    Asset = Struct.new(:service, :key, :url) do
      def blob_path
        service.path_for(key)
      end
    end

    class Engine < ::Rails::Engine
      isolate_namespace Parklife::ActiveStorage

      config.parklife_active_storage = true

      initializer 'parklife.disabled_activestorage_routes' do |app|
        # Disable the standard ActiveStorage routes that will otherwise prevent
        # a ParklifeService blob being served by its dedicated controller.
        app.config.active_storage.draw_routes = false
      end
    end

    mattr_accessor :collect_assets, default: false
    mattr_accessor :collected_assets, default: {}
    mattr_accessor :routes_prefix, default: 'parklife'

    def self.collect_asset(service, key, url)
      collected_assets[key] ||= Asset.new(service, key, url)
    end
  end
end
