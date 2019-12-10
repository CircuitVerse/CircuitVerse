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
    project.check_edit_access(user) || (user.present? && user.admin?)
  end

  def edit_access?
    raise @simulator_exception unless user_access?
    true
  end

  def view_access?
    raise @simulator_exception unless project.check_view_access(user)
    true
  end
  
   def check_edit_access(user)
    @user_access =
        ((!user.nil? and self.author_id == user.id and self.project_submission != true) \
        or (!user.nil? and Collaboration.find_by(project_id:self.id,user_id:user.id)))

  end
  
  def check_view_access(user)
    @user_access =
        (self.project_access_type != "Private" \
        or (!user.nil? and self.author_id==user.id) \
        or (!user.nil? and !self.assignment_id.nil? and self.assignment.group.mentor_id==user.id) \
        or (!user.nil? and Collaboration.find_by(project_id:self.id,user_id:user.id)) \
        or (!user.nil? and user.admin))
  end

  def check_direct_view_access(user)
    @user_access =
        (self.project_access_type == "Public" or \
        (self.project_submission == false and  !user.nil? and self.author_id==user.id) or \
        (!user.nil? and Collaboration.find_by(project_id:self.id,user_id:user.id)) or \
        (!user.nil? and user.admin))
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
