class ProjectsQuery
  attr_reader :relation

  def initialize(relation = Project.all)
    @relation = relation
  end

  def search_name_description(query)
    if ActiveRecord::Base.connection_config["adapter"] === "postgresql"
      full_text_search_name_description(query)
    else
      simple_search_name_description(query)
    end
  end

  def public_and_not_forked
    relation.where(project_access_type: "Public", forked_project_id: nil)
  end

  private

  def full_text_search_name_description(query)
    relation.includes(:author).search(query).
      select("id,author_id,image_preview,name,description,view")
  end

  def simple_search_name_description(query)
    relation.includes(:author)
      .where("name LIKE :query OR description LIKE :query", query: "%#{query}%").
      select("id,author_id,image_preview,name,description,view")
  end

end
