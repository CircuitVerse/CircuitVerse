# frozen_string_literal: true

module Avo
  module Filters
    module ProjectFilters
      class ProjectAccessType < Avo::Filters::SelectFilter
        self.name = "Access Type"

        def apply(_request, query, value)
          return query unless value["featured"]

          query.where(project_access_type: value)
        end

        def options
          {
            "Public" => "Public",
            "Private" => "Private",
            "Limited Access" => "Limited Access"
          }
        end
      end

      class ProjectFeatured < Avo::Filters::BooleanFilter
        self.name = "Featured"

        def apply(_request, query, _value)
          return query if values.values.none?

          values["featured"] ? query.joins(:featured_circuit) : query.where.missing(:featured_circuit)
        end

        def options
          {
            featured: "Featured projects"
          }
        end
      end
    end
  end
end
