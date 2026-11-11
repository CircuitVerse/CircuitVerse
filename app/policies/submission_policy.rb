# frozen_string_literal: true

class SubmissionPolicy < ApplicationPolicy
  attr_reader :user, :submission

  def initialize(user, submission)
    super
    @user = user
    @submission = submission
  end

  def create?
    user.projects.exists?(id: submission.project_id)
  end

  def destroy?
    admin? || submission.project&.author_id == user.id
  end
end
