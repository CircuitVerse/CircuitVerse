class TaggingPolicy < ApplicationPolicy
  attr_reader :user, :tagging

  def initialize(user, tagging)
    @user = user
    @tagging = tagging
  end

  def index?
    user.present? && user.admin?
  end

  def show?
    user.present? && user.admin?
  end

  def create?
    user.present? && user.admin?
  end

  def destroy?
    user.present? && user.admin?
  end

  def update?
    false
  end
end
