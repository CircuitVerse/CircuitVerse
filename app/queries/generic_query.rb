# frozen_string_literal: true

class GenericQuery
  attr_reader :relation

  def initialize(query_params, params_y, relation)
    @search = Search.new(query_params, params_y, relation)
  end

  def results
    @search.call
  end
end
