# frozen_string_literal: true

class Api::V1::AssignmentSerializer
  include FastJsonapi::ObjectSerializer

  attributes :name, :deadline, :description, :status, :restrictions

  attributes :has_mentor_access do |assignment, params|
    (assignment.group.mentor_id == params[:current_user].id) || params[:current_user].admin?
  end

  attributes :created_at, :updated_at, :grading_scale, :grades_finalized
end
