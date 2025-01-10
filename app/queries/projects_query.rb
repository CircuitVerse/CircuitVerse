# frozen_string_literal: true

class ProjectsQuery < GenericQuery
  attr_reader :relation

  def initialize(query_params, params_y, relation = Project.all)
    super query_params, params_y, relation
  end
end
