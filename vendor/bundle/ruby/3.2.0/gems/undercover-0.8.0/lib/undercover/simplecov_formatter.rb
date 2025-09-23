# frozen_string_literal: true

require 'simplecov_json_formatter'

# Patch ResultExporter to allow setting a custom export_path
module SimpleCovJSONFormatter
  class ResultExporter
    def export_path
      # :nocov:
      File.join(SimpleCov.coverage_path, SimpleCov::Formatter::Undercover.output_filename || FILENAME)
      # :nocov:
    end
  end
end

module SimpleCov
  class << self
    attr_accessor :filter_definitions

    alias filtered_uncached filtered

    def filtered(files)
      @filter_definitions ||= extract_filter_definitions
      original_files = files.dup
      filtered_uncached(files).tap do |filtered_files|
        filtered_file_paths = (original_files.map(&:filename) - filtered_files.map(&:filename))
        filtered_file_paths.each do |file|
          relative_path = file.delete_prefix("#{SimpleCov.root}/")
          @filter_definitions << {file: relative_path} unless covered_by_serializable_filters?(relative_path)
        end
      end
    end

    private

    def extract_filter_definitions
      filter_array = []

      filters.each do |filter|
        case filter
        when SimpleCov::StringFilter
          filter_array << {string: filter.filter_argument}
        when SimpleCov::RegexFilter
          filter_array << {regex: filter.filter_argument.source}
        end
      end

      filter_array
    end

    def covered_by_serializable_filters?(relative_path)
      @filter_definitions.any? do |filter_def|
        if filter_def[:string]
          relative_path.include?(filter_def[:string])
        elsif filter_def[:regex]
          relative_path.match?(Regexp.new(filter_def[:regex]))
        end
      end
    end
  end
end

module Undercover
  class ResultHashFormatterWithRoot < SimpleCovJSONFormatter::ResultHashFormatter
    def format
      formatted_result[:meta] = {timestamp: @result.created_at.to_i}
      format_files
      add_undercover_meta_fields
      add_ignored_files
      formatted_result
    end

    private

    def add_undercover_meta_fields
      formatted_result.tap do |result|
        result[:meta].merge!(simplecov_root: SimpleCov.root)
      end
    end

    def add_ignored_files
      formatted_result[:meta][:ignored_files] = SimpleCov.filter_definitions || []
    end

    # format_files uses relative path as keys, as opposed to the superclass method
    def format_files
      formatted_result[:coverage] ||= {}
      @result.files.each do |source_file|
        path = source_file.project_filename.delete_prefix('/')
        formatted_result[:coverage][path] = format_source_file(source_file)
      end
    end
  end

  class UndercoverSimplecovFormatter < SimpleCov::Formatter::JSONFormatter
    class << self
      attr_accessor :output_filename
    end

    def format_result(result)
      result_hash_formater = ResultHashFormatterWithRoot.new(result)
      result_hash_formater.format
    end
  end
end

module SimpleCov
  module Formatter
    Undercover = ::Undercover::UndercoverSimplecovFormatter
  end
end
