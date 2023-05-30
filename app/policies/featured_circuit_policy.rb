# frozen_string_literal: true

class FeaturedCircuitPolicy < ApplicationPolicy
  # @return [User]
  attr_reader :user
  # @return [FeaturedCircuit]
  attr_reader :featured_circuit

  # @param [User] user
  # @param [FeaturedCircuit] featured_circuit
  def initialize(user, featured_circuit)
    @user = user
    @featured_circuit = featured_circuit
  end
end
