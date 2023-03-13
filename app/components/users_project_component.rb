# frozen_string_literal: true

require Rails.root.join('app/policies/project_policy.rb')

class UsersProjectComponent < ViewComponent::Base
  attr_reader :current_user

  def initialize(project:, current_user:)
    super
    @project = project
    @current_user = current_user
  end

  def policy(user)
    ProjectPolicy.new(user, @project)
  end

  def check_direct_view_access?
    policy(current_user).check_direct_view_access?
  end

  def user_access?
    policy(current_user).user_access?
  end
end
