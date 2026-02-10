# frozen_string_literal: true

module Avo
  module Filters
    module StarFilters
      class StarByProject < Avo::Filters::SelectFilter
        self.name = "Project"

        def apply(_request, query, value)
          return query if value.blank?

          query.where(project_id: value)
        end

        def options
          Project.order(:name).pluck(:name, :id).to_h
        end
      end

      class StarByUser < Avo::Filters::SelectFilter
        self.name = "User"

        def apply(_request, query, value)
          return query if value.blank?

          query.where(user_id: value)
        end

        def options
          User.order(:name).pluck(:name, :id).to_h
        end
      end
    end
  end
end
