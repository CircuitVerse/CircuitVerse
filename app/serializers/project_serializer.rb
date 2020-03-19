class ProjectSerializer
  include FastJsonapi::ObjectSerializer

  attributes :name, :project_access_type, :created_at,
             :updated_at, :image_preview, :description,
             :view
  belongs_to :author

end
