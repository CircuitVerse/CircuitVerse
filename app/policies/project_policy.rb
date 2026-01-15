# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  attr_reader :user, :project

  def initialize(user, project)
    @user = user
    @project = project
    simulator_error = "Project has been moved or deleted. If you are the owner " \
                      "of the project, Please check your project access privileges."
    @simulator_exception = CustomAuthException.new(simulator_error)
  end

  def can_feature?
    user.present? && user.admin? && project.project_access_type == "Public"
  end

  def user_access?
    check_edit_access? || (user.present? && user.admin?)
  end

  def check_edit_access?
    return false if user.nil? || project.project_submission

    project.author_id == user.id ||
      collaborator_access?
  end

  def check_view_access?
    project.project_access_type != "Private" ||
      author_access? ||
      mentor_access? ||
      collaborator_access? ||
      (user.present? && user.admin)
  end

  def check_direct_view_access?
    project.project_access_type == "Public" ||
      (project.project_submission == false && author_access?) ||
      collaborator_access? ||
      (user.present? && user.admin)
  end

  private

  def mentor_access?
    return false if user.nil? || project.assignment_id.nil?

    group = project.assignment.group
    group.primary_mentor_id == user.id ||
      group.group_members.exists?(user_id: user.id, mentor: true)
  end

  def collaborator_access?
    return false if user.nil?

    project.collaborations.any? { |c| c.user_id == user.id }
  end

  def edit_access?
    raise @simulator_exception unless user_access?

    true
  end

  def view_access?
    raise @simulator_exception unless check_view_access?

    true
  end

  def direct_view_access?
    raise @simulator_exception unless check_direct_view_access?

    true
  end

  def embed?
    raise @simulator_exception unless project.project_access_type != "Private"

    true
  end

  def create_fork?
    project.assignment_id.nil?
  end

  def author_access?
    (user.present? && user.admin?) || project.author_id == (user.present? && user.id)
  end
end
