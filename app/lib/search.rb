# frozen_string_literal: true

class Search
  def initialize(relation)
    @relation = relation

    @adapter =  Adapters::PgAdapter.new
  end

  def call(query)
    @adapter.send("search_#{@relation.name.downcase}", @relation, query)
  end
end
