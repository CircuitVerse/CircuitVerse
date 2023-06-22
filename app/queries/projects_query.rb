# frozen_string_literal: true

class ProjectsQuery < GenericQuery
  # @return [ActiveRecord::Relation]
  attr_reader :relation

  # @param [Hash] query_params
  # @param [ActiveRecord::Relation] relation
  def initialize(query_params, relation = Project.all)
    super query_params, relation
  end
end
