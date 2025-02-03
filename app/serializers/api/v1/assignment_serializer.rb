# frozen_string_literal: true

class Api::V1::AssignmentSerializer
  include FastJsonapi::ObjectSerializer

  attributes :name, :deadline, :description, :status, :restrictions

  attributes :has_primary_mentor_access do |assignment, params|
    (assignment.group.primary_mentor_id == params[:current_user].id) || params[:current_user].admin?
  end

  attributes :current_user_project_id do |assignment, params|
    # checks for project related to the assignment, returns null if no project found else project_id
    project = assignment.projects.find_by(author_id: params[:current_user].id)
    project&.id
  end

  attributes :created_at, :updated_at, :grading_scale, :grades_finalized

  has_many :projects
  has_many :grades
end
