# frozen_string_literal: true

class Avo::Filters::ProjectAccessType < Avo::Filters::SelectFilter
  self.name = "Access Type"

  def apply(_request, query, value)
    query.where(project_access_type: value)
  end

  def options
    {
      "Public" => "Public",
      "Private" => "Private",
      "Limited Access" => "Limited Access"
    }
  end
end
