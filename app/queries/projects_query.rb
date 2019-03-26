# frozen_string_literal: true
class ProjectsQuery
  attr_reader :relation

  def initialize(relation = Project.all)
    @relation = relation
  end

  def public_and_not_forked
    relation.where(project_access_type: "Public", forked_project_id: nil)
  end

  def search_name_description(query)
    relation.includes(:author).search(query).
      select("id,author_id,image_preview,name,description,view")
  end
end
