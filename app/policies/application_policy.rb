# frozen_string_literal: true

# TODO: record and scope check if specific Object type present
class ApplicationPolicy
  # @return [User]
  attr_reader :user
  # @return [ApplicationRecord]
  attr_reader :record

  class CustomAuthException < StandardError
    # @return [String]
    attr_reader :custom_message

    # @param [String] custom_message
    def initialize(custom_message)
      @custom_message = custom_message
    end
  end

  # @param [User] user
  # @param [ApplicationRecord] record
  def initialize(user, record)
    record.fin
    raise Pundit::NotAuthorizedError, "User must be logged in" unless user

    @user = user
    @record = record
  end

  # @return [Boolean]
  def index?
    false
  end

  # @return [Boolean]
  def show?
    false
  end

  # @return [Boolean]
  def create?
    false
  end

  # @return [Boolean]
  def new?
    create?
  end

  # @return [Boolean]
  def update?
    false
  end

  # @return [Boolean]
  def edit?
    update?
  end

  # @return [Boolean]
  def destroy?
    false
  end

  # @return [Boolean]
  def admin?
    user.present? && user.admin?
  end

  class Scope
    # @return [User]
    attr_reader :user
    # @return [Object]
    attr_reader :scope

    # @param [User] user
    # @param [Object] scope
    def initialize(user, scope)
      raise Pundit::NotAuthorizedError, "User must be logged in" unless user

      @user = user
      @scope = scope
    end

    # @return [Array<Object>]
    def resolve
      scope.all
    end
  end
end
