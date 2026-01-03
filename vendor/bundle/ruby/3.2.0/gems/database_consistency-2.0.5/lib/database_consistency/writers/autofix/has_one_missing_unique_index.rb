# frozen_string_literal: true

module DatabaseConsistency
  module Writers
    module Autofix
      class HasOneMissingUniqueIndex < AssociationMissingIndex # :nodoc:
        def attributes
          super.merge(unique: true)
        end

        private

        def template_path
          File.join(__dir__, 'templates', 'has_one_missing_unique_index.tt')
        end
      end
    end
  end
end
