# frozen_string_literal: true

module ProfanityFilterable
  extend ActiveSupport::Concern

  included do
    validate :check_profanity
  end

  def check_profanity
    # Fields to check for profanity
    attributes_to_check = %w[name description]

    attributes_to_check.each do |attribute|
      next unless respond_to?(attribute) && send(attribute).present?

      profanity_filter = LanguageFilter::Filter.new matchlist: :profanity
      errors.add(attribute.to_sym, "contains inappropriate language") if profanity_filter.match?(send(attribute))
    end
  end
end
