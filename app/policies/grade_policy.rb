# frozen_string_literal: true

class GradePolicy < ApplicationPolicy
  attr_reader :user, :grade

  def initialize(user, grade)
    @user = user
    @grade = grade
  end

  def mentor?
    grade.assignment&.group&.primary_mentor_id == user.id \
    || grade.assignment&.group&.group_members&.exists?(user_id: user.id, mentor: true)
  end
end
