# frozen_string_literal: true

class Avo::Filters::BlobIdFilter < Avo::Filters::TextFilter
  self.name = "Blob ID"
  self.button_label = "Filter by Blob ID"

  def apply(_request, query, value)
    query.where(blob_id: value)
  end
end
