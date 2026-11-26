# frozen_string_literal: true

class CollaborationPolicy < ApplicationPolicy
  attr_reader :user, :collaboration

  def initialize(user, collaboration)
    super
    @user = user
    @collaboration = collaboration
  end

  # The project author or an admin can remove any collaborator.
  # A collaborator can also remove themselves, which means leaving the project.
  def destroy?
    collaboration.user_id == user.id ||
      ProjectPolicy.new(user, collaboration.project).author_access?
  end
end
