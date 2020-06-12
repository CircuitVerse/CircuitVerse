# frozen_string_literal: true

class Api::V1::AssignmentSerializer
  include FastJsonapi::ObjectSerializer

  attributes :name, :deadline, :description, :status, :restrictions

  attributes :has_mentor_access do |assignment, params|
    (assignment.group.mentor_id == params[:current_user].id) || params[:current_user].admin?
  end

  attributes :your_project_id do |assignment, params|
    # checks for project related to the assignment, returns null if no project found or project_id
    project = assignment.projects.find { |p| p.author_id == params[:current_user].id }
    project.nil? ? nil : project.id
  end

  attributes :created_at, :updated_at, :grading_scale, :grades_finalized
end
