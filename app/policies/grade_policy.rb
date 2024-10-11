# frozen_string_literal: true

class GradePolicy < ApplicationPolicy
  # @return [User]
  attr_reader :user
  # @return [Grade]
  attr_reader :grade

  # @param [User] user
  # @param [Grade] grade
  def initialize(user, grade)
    @user = user
    @grade = grade
  end

  # Verify if the user is a mentor of the group
  # @return [Boolean]
  def mentor?
    grade.assignment&.group&.primary_mentor_id == user.id \
    || grade.assignment&.group&.group_members&.exists?(user_id: user.id, mentor: true)
  end
end
