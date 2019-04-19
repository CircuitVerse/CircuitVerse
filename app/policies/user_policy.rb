# frozen_string_literal: true

class UserPolicy < Struct.new(:user, :requested_user)
  attr_reader :user, :requested_user

  def initialize(user, requested_user)
    @user = user
    @requested_user = requested_user
  end

  def groups?
    requested_user.id == user.id || user.admin?
  end

  def edit?
    requested_user.id == user.id
  end
end
