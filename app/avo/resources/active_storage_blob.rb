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

    field :byte_size, as: :text do
      ActionController::Base.helpers.number_to_human_size(record.byte_size)
    end

    field :checksum, as: :text
    field :metadata, as: :code, language: :json

    # Image preview using external_image field type
    field :image_preview, as: :external_image, only_on: :show do
      if record.image?
        Rails.application.routes.url_helpers.rails_blob_path(
          record,
          only_path: true
        )
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
end
