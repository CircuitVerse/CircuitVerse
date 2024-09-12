# frozen_string_literal: true

class QuestionCategoryPolicy < ApplicationPolicy
  attr_reader :user, :question_category

  def initialize(user, question_category)
    @user = user
    @question_category = question_category
  end
end
