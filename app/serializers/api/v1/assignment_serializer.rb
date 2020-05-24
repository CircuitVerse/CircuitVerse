# frozen_string_literal: true

class Api::V1::AssignmentSerializer
  include FastJsonapi::ObjectSerializer

  attributes :name, :deadline, :description, :created_at,
             :updated_at, :status, :grading_scale, :grades_finalized,
             :restrictions
end
