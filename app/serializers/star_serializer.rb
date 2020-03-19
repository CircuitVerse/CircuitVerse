class StarSerializer
  include FastJsonapi::ObjectSerializer

  attributes :user_id, :project_id
  belongs_to :user
  belongs_to :project

end
