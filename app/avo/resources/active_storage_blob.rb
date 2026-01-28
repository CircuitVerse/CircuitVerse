# frozen_string_literal: true

class Avo::Resources::ActiveStorageBlob < Avo::BaseResource
  self.title = :id
  self.includes = %i[attachments variant_records]
  self.model_class = ::ActiveStorage::Blob
  self.visible_on_sidebar = true
  self.index_query = -> { query.order(created_at: :desc) }

  def fields
    field :id, as: :id, link_to_record: true
    field :key, as: :text

    # Filename - display only on show/index, hide on edit to avoid errors
    field :filename, as: :text, hide_on: [:edit]

    field :content_type, as: :text
    field :service_name, as: :text

    field :byte_size, as: :number, hide_on: [:edit] do
      number_to_human_size(record.byte_size) if record.byte_size.present?
    end

    field :checksum, as: :text
    field :metadata, as: :code, language: :json
    field :created_at, as: :date_time, readonly: true

    field :attachments, as: :has_many, hide_on: %i[edit new]
    field :variant_records, as: :has_many, class_name: "ActiveStorage::VariantRecord", hide_on: %i[edit new]
  end

  def filters
    filter Avo::Filters::BlobByContentType
    filter Avo::Filters::BlobByServiceName
  end

  def actions
    action Avo::Actions::DownloadBlob
  end
end
