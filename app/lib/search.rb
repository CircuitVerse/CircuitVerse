# frozen_string_literal: true

class Search
  def initialize(query_params, params_y, relation)
    @relation = relation
    @query_params = query_params
    @params_y = params_y
    @adapter = if ENV["CIRCUITVERSE_USE_SOLR"] == "true"
      Adapters::SolrAdapter.new
    else
      Adapters::PgAdapter.new
    end
  end

  # calling the adapter to search the relation
  def call
    @adapter.send("search_#{@relation.name.downcase}", @relation, @query_params, @params_y)
  end
end
