# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  attr_reader :current_user, :requested_user

  # Overrides ApplicationPolicy's login requirement because public profile
  # pages evaluate this policy for anonymous visitors.
  def initialize(current_user, requested_user)
    @current_user = current_user
    @requested_user = requested_user
  end

  def groups?
    current_user.present? && (requested_user.id == current_user.id || current_user.admin?)
  end

  def edit?
    current_user.present? && requested_user.id == current_user.id
  end
end
