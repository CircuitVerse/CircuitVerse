# frozen_string_literal: true

class CollaborationPolicy < ApplicationPolicy
  attr_reader :user, :collaboration

  def initialize(user, collaboration)
    @user = user
    @collaboration = collaboration
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

  def update?
    false
  end

  def destroy?
    user.present? && user.admin?
  end
end
