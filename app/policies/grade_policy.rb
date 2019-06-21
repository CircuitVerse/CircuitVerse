# frozen_string_literal: true

class GradePolicy < ApplicationPolicy
  attr_reader :user, :grade

  def initialize(user, grade)
    @user = user
    @grade = grade
  end

  def mentor?
    grade.assignment&.group&.mentor_id == user.id && !grade.assignment&.grades_finalized
  end
end
