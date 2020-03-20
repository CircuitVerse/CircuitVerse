class FeaturedCircuitSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :project_id
  belongs_to :project

end
