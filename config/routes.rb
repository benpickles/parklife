# frozen_string_literal: true
Rails.application.routes.draw do
  scope Parklife::ActiveStorage.routes_prefix do
    get 'blobs/:key/*filename',
      to: 'parklife/active_storage/blobs#show',
      as: :parklife_blob_service
  end

  direct :parklife_blob do |blob, options|
    route_for(
      :parklife_blob_service,
      blob.key,
      blob.filename,
      { only_path: true }.merge(options),
    )
  end

  resolve('ActiveStorage::Attachment')        { |attachment, options| route_for(:parklife_blob, attachment.blob, options) }
  resolve('ActiveStorage::Blob')              { |blob, options| route_for(:parklife_blob, blob, options) }
  resolve('ActiveStorage::Preview')           { |preview, options| route_for(:parklife_blob, preview.blob, options) }
  resolve('ActiveStorage::VariantWithRecord') { |variant, options| route_for(:parklife_blob, variant.blob, options) }
end
