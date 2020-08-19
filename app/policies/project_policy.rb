# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  attr_reader :user, :project

  def initialize(user, project)
    @user = user
    @project = project
    simulator_error = "Project has been moved or deleted. If you are the owner"\
            " of the project, Please check your project access privileges."
    @simulator_exception = CustomAuthException.new(simulator_error)
  end

  def can_feature?
    user.present? && user.admin? && project.project_access_type == "Public"
  end

  def user_access?
    check_edit_access? || (user.present? && user.admin?)
  end

  def check_edit_access?
    ((!user.nil? && project.author_id == user.id && project.project_submission != true) \
    || (!user.nil? && Collaboration.exists?(project_id: project.id, user_id: user.id)))
  end

  def check_view_access?
    (project.project_access_type != "Private" \
    || (!user.nil? && project.author_id == user.id) \
    || (!user.nil? && !project.assignment_id.nil? \
      && project.assignment.group.mentor_id == user.id) \
    || (!user.nil? && Collaboration.exists?(project_id: project.id, user_id: user.id)) \
    || (!user.nil? && user.admin))
  end

  def check_direct_view_access?
    (project.project_access_type == "Public"  \
    || (project.project_submission == false && !user.nil? && project.author_id == user.id) \
    || (!user.nil? && Collaboration.exists?(project_id: project.id, user_id: user.id)) \
    || (!user.nil? && user.admin))
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
