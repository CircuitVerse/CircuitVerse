# frozen_string_literal: true

class ProjectsSerializer
  include FastJsonapi::ObjectSerializer
  set_type :projects
  attribute :name
end
