# frozen_string_literal: true

class FeaturedCircuitPolicy < ApplicationPolicy
  attr_reader :user, :featured_circuit

  def initialize(user, featured_circuit)
    @user = user
    @featured_circuit = featured_circuit
  end
end
