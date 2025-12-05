# frozen_string_literal: true

# Handles JSON parsing and validation for project data
# Provides methods for safely parsing JSON that may be truncated or corrupted
module JsonDataHandler
  extend ActiveSupport::Concern

  private

    def update_datum_name(raw_data, new_name)
      datum_data = JSON.parse(raw_data)
      datum_data["name"] = new_name
      @project.project_datum.data = JSON.generate(datum_data)
    rescue JSON::ParserError => e
      log_json_parse_error(e, raw_data)
    end

    def log_truncated_data(raw_data)
      Rails.logger.warn(
        "Skipping project datum update for project #{@project.id}: " \
        "data appears to be truncated (size: #{raw_data.bytesize} bytes)"
      )
    end

    def log_json_parse_error(error, raw_data)
      Rails.logger.error(
        "JSON parsing failed for project #{@project.id} during update: " \
        "#{error.message} (data size: #{raw_data.bytesize} bytes)"
      )
      return unless defined?(Sentry)

      Sentry.capture_exception(error,
                               extra: { project_id: @project.id, data_size: raw_data.bytesize })
    end

    def truncated_json?(data)
      return true if data.blank?

      stripped = data.strip
      return true if stripped.empty?

      invalid_json_structure?(stripped)
    end

    def invalid_json_structure?(data)
      first_char = data[0]
      last_char = data[-1]

      case first_char
      when "{" then last_char != "}"
      when "[" then last_char != "]"
      else true # Project data should always be JSON objects
      end
    end
end
