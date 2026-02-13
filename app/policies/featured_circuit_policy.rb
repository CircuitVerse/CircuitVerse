# frozen_string_literal: true

class FeaturedCircuitPolicy < ApplicationPolicy
  attr_reader :user, :featured_circuit

  def initialize(user, featured_circuit)
    @user = user
    @featured_circuit = featured_circuit
  end

  def index?
    user&.admin?
  end

  def show?
    user&.admin?
  end

  def create?
    user&.admin?
  end

  def update?
    user&.admin?
  end

  def destroy?
    user&.admin?
  end
end
