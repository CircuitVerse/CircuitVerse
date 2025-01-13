# frozen_string_literal: true

module ProjectValidations
  extend ActiveSupport::Concern
  include LanguageFilterable

  included do
    validates :name, length: { minimum: 1 }
    validates :description, length: { maximum: 10_000 }
    validates :slug, uniqueness: true

    validate :check_validity
    validate :clean_description
  end

  private

    def check_validity
      return unless (project_access_type != "Private") && !assignment_id.nil?

      errors.add(:project_access_type, "Assignment has to be private")
    end

    def clean_description
      language_filters = create_language_filters

      description_matches = check_language_filters(language_filters, description)

      return nil if description_matches.empty?

      errors.add(
        :description,
        "contains inappropriate language in description: #{description_matches.join(', ')}"
      )
    end
end
