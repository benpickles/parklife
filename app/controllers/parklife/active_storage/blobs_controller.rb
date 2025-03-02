# frozen_string_literal: true
module Parklife
  module ActiveStorage
    class BlobsController < ActionController::Base
      include ::ActiveStorage::FileServer

      def show
        blob = ::ActiveStorage::Blob.find_by!(key: params[:key])

        serve_file(
          named_disk_service(blob.service_name).path_for(blob.key),
          content_type: blob.content_type,
          disposition: :inline,
        )
      rescue Errno::ENOENT
        head :not_found
      end

      private
        def named_disk_service(name)
          ::ActiveStorage::Blob.services.fetch(name)
        end
    end
  end
end
