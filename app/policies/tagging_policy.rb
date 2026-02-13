# frozen_string_literal: true

class TaggingPolicy < ApplicationPolicy
  def index?
    user.present? && user.admin?
  end

  def show?
    user.present? && user.admin?
  end

  def create?
    user.present? && user.admin?
  end

  def update?
    false
  end

  def destroy?
    user.present? && user.admin?
  end
end
