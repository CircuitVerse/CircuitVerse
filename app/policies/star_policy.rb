# frozen_string_literal: true

class StarPolicy < ApplicationPolicy
  attr_reader :user, :star

  def initialize(user, star)
    @user = user
    @star = star
  end

  def index?
    user.present? && user.admin?
  end

  def show?
    user.present? && user.admin?
  end

  def create?
    false
  end

  def update?
    false
  end

  def destroy?
    user.present? && user.admin?
  end
end
