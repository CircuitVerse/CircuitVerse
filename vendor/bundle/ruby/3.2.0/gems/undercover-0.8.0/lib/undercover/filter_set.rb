# frozen_string_literal: true

module Undercover
  class FilterSet
    attr_reader :allow_filters, :reject_filters, :simplecov_filters

    def initialize(allow_filters, reject_filters, simplecov_filters)
      @allow_filters = allow_filters || []
      @reject_filters = reject_filters || []
      @simplecov_filters = simplecov_filters || []
    end

    def include?(filepath)
      fnmatch = proc { |glob| File.fnmatch(glob, filepath, File::FNM_EXTGLOB) }

      # Check if file was ignored by SimpleCov filters
      return false if ignored_by_simplecov?(filepath)

      # Apply Undercover's own filters
      allow_filters.any?(fnmatch) && reject_filters.none?(fnmatch)
    end

    private

    def ignored_by_simplecov?(filepath)
      simplecov_filters.any? do |filter|
        if filter[:string]
          filepath.include?(filter[:string])
        elsif filter[:regex]
          filepath.match?(Regexp.new(filter[:regex]))
        elsif filter[:file]
          filepath == filter[:file]
        end
      end
    end
  end
end
