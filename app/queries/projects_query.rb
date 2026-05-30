# frozen_string_literal: true

class ProjectsQuery < GenericQuery
  attr_reader :relation

  def initialize(query_params, relation = Project.all)
    super
  end
end
