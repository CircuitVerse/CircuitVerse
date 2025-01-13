# frozen_string_literal: true

module LanguageFilterable
  extend ActiveSupport::Concern

  private

    def check_language_filters(filters, text)
      filters.flat_map do |filter|
        filter.matched(text) if filter.match?(text)
      end.compact.uniq
    end

    def create_language_filters
      matchlists = %i[profanity hate violence]
      matchlists.map { |list| LanguageFilter::Filter.new(matchlist: list) }
    end
end
