# frozen_string_literal: true

class ContestPolicy < ApplicationPolicy
  def initialize(user, contest)
    @user = user
    @contest = contest
  end

  def admin?
    user.present? && user.admin?
  end
end
