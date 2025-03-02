# frozen_string_literal: true
require 'active_storage/service/disk_service'

module ActiveStorage
  class Service::ParklifeService < Service::DiskService
    def url(key, **options)
      super.tap do |url|
        if Parklife::ActiveStorage.collect_assets
          Parklife::ActiveStorage.collect_asset(self, key, url)
        end
      end
    end

    private
      def generate_url(key, expires_in:, filename:, content_type:, disposition:)
        url_helpers.parklife_blob_service_path(key: key, filename: filename)
      end
  end
end
