# frozen_string_literal: true

module Adapters
  class PgAdapter < BaseAdapter
    def search_project(relation, query)
      if query.present?
        relation.text_search(query)
      else
        Project.public_and_not_forked
      end
    end

    def search_user(relation, query)
      if query.present?
        relation.text_search(query)
      else
        User.all
      end
    end
  end
end
