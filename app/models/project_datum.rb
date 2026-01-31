# frozen_string_literal: true

class ProjectDatum < ApplicationRecord
  belongs_to :project

  # Maximum recommended data size (adjust based on your server configuration)
  # Set conservatively below your web server limit to account for HTTP overhead
  MAX_DATA_SIZE = 10.megabytes

  validate :check_data_size

  private

    def check_data_size
      return if data.blank?

      data_size = data.bytesize

      if data_size > MAX_DATA_SIZE
        errors.add(
          :data,
          "Circuit data is too large (#{format_bytes(data_size)}). " \
          "Maximum size is #{format_bytes(MAX_DATA_SIZE)}. " \
          "Please simplify your circuit or remove unused components."
        )
      elsif data_size > (MAX_DATA_SIZE * 0.8)
        # Warning threshold at 80%
        Rails.logger.warn("Project #{project_id} approaching size limit: #{format_bytes(data_size)}")
      end
    end

    def format_bytes(bytes)
      if bytes < 1024
        "#{bytes} B"
      elsif bytes < 1024 * 1024
        "#{(bytes / 1024.0).round(2)} KB"
      else
        "#{(bytes / (1024.0 * 1024)).round(2)} MB"
      end
    end
end
