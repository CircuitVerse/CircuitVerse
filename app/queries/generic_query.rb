# frozen_string_literal: true

class GenericQuery
  attr_reader :relation

  def initialize(query_params, relation)
    @search = Search.new(query_params, relation)
  end

  def results
    @search.call
  end
end
