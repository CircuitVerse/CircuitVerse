# frozen_string_literal: true

class ProjectDatumPolicy < ApplicationPolicy
  attr_reader :user, :project_datum

  def initialize(user, project_datum)
    @user = user
    @project_datum = project_datum
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
