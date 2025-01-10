# frozen_string_literal: true

class UsersQuery < GenericQuery
  attr_reader :relation

  def initialize(query_params, params_y, relation = User.all)
    super query_params, params_y, relation
  end
end
