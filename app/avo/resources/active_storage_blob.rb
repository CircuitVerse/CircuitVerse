# frozen_string_literal: true

class Avo::Resources::ActiveStorageBlob < Avo::BaseResource
  self.title = :id
  self.model_class = ::ActiveStorage::Blob
  self.includes = %i[attachments variant_records]
  # rubocop:disable Metrics/MethodLength

  def fields
    field :id, as: :id
    field :key, as: :text

    field :filename, as: :text do
      record.filename.to_s
    end

    field :content_type, as: :text
    field :service_name, as: :text

    field :byte_size, as: :number do
      ActionController::Base.helpers.number_to_human_size(record.byte_size)
    end

    field :checksum, as: :text
    field :metadata, as: :code, language: :json

    # ✅ WORKING IMAGE PREVIEW
    field :image_preview, as: :text, only_on: :show do
      if record.image?
        ActionController::Base.helpers.image_tag(
          Rails.application.routes.url_helpers.rails_blob_path(
            record,
            only_path: true
          ),
          class: "max-w-xs rounded border"
        )
      else
        "Not an image"
      end
    end

    field :attachments_count, as: :number do
      record.attachments.count
    end

    field :variant_records_count, as: :number do
      record.variant_records.count
    end

    field :created_at, as: :date_time

    field :attachments, as: :has_many
    field :variant_records, as: :has_many
  end
  # rubocop:enable Metrics/MethodLength

  def filters
    filter Avo::Filters::BlobByContentType
    filter Avo::Filters::BlobByServiceName
    filter Avo::Filters::BlobCreatedAt
  end

  def actions
    action Avo::Actions::DownloadBlob
    action Avo::Actions::ExportBlobs
  end
end
