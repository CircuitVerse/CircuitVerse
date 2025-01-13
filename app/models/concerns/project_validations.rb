# frozen_string_literal: true

module ProjectValidations
  extend ActiveSupport::Concern

  included do
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
      matchlists = %i[profanity hate violence]
      language_filters = matchlists.map { |list| LanguageFilter::Filter.new(matchlist: list) }

      description_matches = check_language_filters(language_filters, description)

      return nil if description_matches.empty?

      errors.add(
        :description,
        "contains inappropriate language: #{description_matches.join(', ')}"
      )
    end

    def check_language_filters(filters, text)
      filters.flat_map do |filter|
        filter.matched(text) if filter.match?(text)
      end.compact.uniq
    end
end
