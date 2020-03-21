class ProjectSerializer
  include FastJsonapi::ObjectSerializer
  set_type :projects
  attributes :image_preview, :description, :view, :tags, :name
  attributes :author do |project|
    "#{project.author.name}"
  end
  attributes :stars_count do |proj|
    proj.stars.count
  end
  attributes :link_to_project do |project|
    "/users/#{project.author.id}/projects/#{project.id}"
  end
end
