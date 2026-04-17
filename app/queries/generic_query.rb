# frozen_string_literal: true

class GenericQuery
  # @return [ActiveRecord::Relation]
  attr_reader :relation

  # @param [Hash] query_params
  # @param [ActiveRecord::Relation] relation
  def initialize(query_params, relation)
    @search = Search.new(query_params, relation)
  end

  # @return [Array] an array of search results
  def results
    @search.call
  end
end
