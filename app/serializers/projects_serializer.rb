# frozen_string_literal: true
class ProjectsSerializer
  include FastJsonapi::ObjectSerializer
  set_type :projects
  attribute :name, if: Proc.new { |params|
    params[:project_access_type] == "Public"
  }
end
