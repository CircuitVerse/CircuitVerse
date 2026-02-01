# frozen_string_literal: true

class Avo::Filters::VariationDigestFilter < Avo::Filters::TextFilter
  self.name = "Variation Digest"
  self.button_label = "Filter by Variation Digest"

  def apply(_request, query, value)
    query.where("variation_digest LIKE ?", "%#{value}%")
  end
end
