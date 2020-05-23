# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  class CustomAuthException < StandardError
    attr_reader :custom_message

    def initialize(custom_message)
      @custom_message = custom_message
    end
  end

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "User must be logged in" unless user

    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def admin?
    user.present? && user.admin?
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      raise Pundit::NotAuthorizedError, "User must be logged in" unless user

      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end
end
