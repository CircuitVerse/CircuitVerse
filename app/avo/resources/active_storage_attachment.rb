# frozen_string_literal: true

class Avo::Resources::ActiveStorageAttachment < Avo::BaseResource
  self.title = :name
  self.includes = %i[blob record]
  self.model_class = ::ActiveStorage::Attachment

  self.visible_on_sidebar = true
  self.index_query = -> { query.order(created_at: :desc) }

  def fields
    field :id, as: :id, link_to_record: true
    field :name, as: :text

    # Polymorphic record association
    field :record_type, as: :text, hide_on: %i[new edit]
    field :record_id, as: :number, hide_on: %i[new edit]

    field :record, as: :belongs_to, polymorphic_as: :record, types: [
      ::User,
      ::Project
    ], searchable: true

    field :blob, as: :belongs_to, searchable: true
    field :created_at, as: :date_time, hide_on: %i[new edit]
  end

  def filters
    filter Avo::Filters::AttachmentByRecordType
    filter Avo::Filters::AttachmentByName
  end
end
