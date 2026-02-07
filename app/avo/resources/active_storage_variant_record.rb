# frozen_string_literal: true

class Avo::Resources::ActiveStorageVariantRecord < Avo::BaseResource
  self.title = :id
  self.includes = [:blob]
  self.model_class = ::ActiveStorage::VariantRecord

  self.visible_on_sidebar = true
  self.index_query = -> { query.order(id: :desc) }

  def fields
    field :id, as: :id, link_to_record: true
    field :blob, as: :belongs_to, searchable: true
    field :variation_digest, as: :text

    # Image field for variant
    field :image, as: :file, is_image: true
  end

  def filters
    filter Avo::Filters::BlobIdFilter
    filter Avo::Filters::VariationDigestFilter
  end

  def actions
    action Avo::Actions::ExportVariantRecords
  end
end
