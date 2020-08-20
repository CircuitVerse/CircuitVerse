# frozen_string_literal: true

class Api::V1::GradeSerializer
  include FastJsonapi::ObjectSerializer

  attributes :grade, :remarks, :created_at, :updated_at

  belongs_to :project
end
