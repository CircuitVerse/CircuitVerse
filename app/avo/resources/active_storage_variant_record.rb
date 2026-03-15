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

    # Preview of the variant through its blob
    field :variant_preview, as: :text, only_on: :show do
      if record.blob&.image?
        "Variant of blob ##{record.blob_id} (digest: #{record.variation_digest})"
      else
        "Not an image variant"
      end
    end
  end
end
