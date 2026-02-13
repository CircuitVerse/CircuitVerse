# frozen_string_literal: true

class ProjectDatum < ApplicationRecord
  belongs_to :project

  MAX_DATA_SIZE = 5.megabytes

  validate :validate_data_size
  validate :validate_json_structure

  private

  def validate_data_size
    return if data.blank?

    if data.to_json.bytesize > MAX_DATA_SIZE
      errors.add(:data, "Payload exceeds 5MB limit")
    end
  end

  def validate_json_structure
    return if data.blank?

    validator = ProjectDatumValidator.new(data)

    unless validator.valid?
      errors.add(:data, validator.error_message)
    end
  end
end
