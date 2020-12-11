# frozen_string_literal: true

UserPolicy = Struct.new(:user, :requested_user) do
  attr_reader :current_user, :requested_user

  def initialize(current_user, requested_user)
    @current_user = current_user
    @requested_user = requested_user
  end

  def groups?
    requested_user.id == current_user.id || current_user.admin?
  end

  def edit?
    current_user && requested_user.id == current_user.id
  end
end
