# frozen_string_literal: true

class UsersQuery
  MAX_RESULTS_PER_PAGE = 5

  attr_reader :relation

  def initialize(relation = User.all)
    @search = Search.new(relation)
  end

  def execute(query)
    @search.call(query)
  end

  def results(query_params)
    execute(query_params[:q]).paginate(page: query_params[:page],
        per_page: MAX_RESULTS_PER_PAGE)
  end
end
