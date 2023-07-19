# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  # @return [User]
  attr_reader :user
  # @return [Project]
  attr_reader :project

  # @param [User] user
  # @param [Project] project
  def initialize(user, project)
    @user = user
    @project = project
    simulator_error = "Project has been moved or deleted. If you are the owner " \
                      "of the project, Please check your project access privileges."
    @simulator_exception = CustomAuthException.new(simulator_error)
  end

  # @return [Boolean]
  def can_feature?
    user.present? && user.admin? && project.project_access_type == "Public"
  end

  # @return [Boolean]
  def user_access?
    check_edit_access? || (user.present? && user.admin?)
  end

  # @return [Boolean]
  def check_edit_access?
    return false if user.nil? || project.project_submission

    project.author_id == user.id ||
      Collaboration.exists?(project_id: project.id, user_id: user.id)
  end

  # @return [Boolean]
  def check_view_access?
    (project.project_access_type != "Private" ||
    (!user.nil? && project.author_id == user.id) ||
    (!user.nil? && !project.assignment_id.nil? &&
    ((project.assignment.group.primary_mentor_id == user.id) ||
    project.assignment.group.group_members.exists?(user_id: user.id, mentor: true))) ||
    (!user.nil? && Collaboration.exists?(project_id: project.id, user_id: user.id)) ||
    (!user.nil? && user.admin))
  end

  # @return [Boolean]
  def check_direct_view_access?
    (project.project_access_type == "Public" ||
    (project.project_submission == false && !user.nil? && project.author_id == user.id) ||
    (!user.nil? && Collaboration.exists?(project_id: project.id, user_id: user.id)) ||
    (!user.nil? && user.admin))
  end

  # @return [Boolean]
  def edit_access?
    raise @simulator_exception unless user_access?

    true
  end

  # @return [Boolean]
  def view_access?
    raise @simulator_exception unless check_view_access?

    true
  end

  # @return [Boolean]
  def direct_view_access?
    raise @simulator_exception unless check_direct_view_access?

    true
  end

  # @return [Boolean]
  def embed?
    raise @simulator_exception unless project.project_access_type != "Private"

    true
  end

  # @return [Boolean]
  def create_fork?
    project.assignment_id.nil?
  end

  # @return [Boolean]
  def author_access?
    (user.present? && user.admin?) || project.author_id == (user.present? && user.id)
  end
end
