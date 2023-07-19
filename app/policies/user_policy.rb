# frozen_string_literal: true

UserPolicy = Struct.new(:user, :requested_user) do
  # @return [User]
  attr_reader :current_user
  # @return [User]
  attr_reader :requested_user

  # @param [User] current_user
  # @param [User] requested_user
  def initialize(current_user, requested_user)
    @current_user = current_user
    @requested_user = requested_user
  end

  # @return [Boolean]
  def groups?
    requested_user.id == current_user.id || current_user.admin?
  end

  # @return [Boolean]
  def edit?
    current_user && requested_user.id == current_user.id
  end
end
