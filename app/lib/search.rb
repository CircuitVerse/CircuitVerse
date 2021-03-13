# frozen_string_literal: true

class Search
  def initialize(query_params, relation)
    @relation = relation
    @query_params = query_params
    @adapter = if ENV["CIRCUITVERSE_USE_SOLR"] == "true"
      Adapters::SolrAdapter.new
    else
      Adapters::PgAdapter.new
    end
  end

  def call
    @adapter.send("search_#{@relation.name.downcase}", @relation, @query_params)
  end
end
