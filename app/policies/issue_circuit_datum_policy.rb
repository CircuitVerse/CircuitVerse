# frozen_string_literal: true

class IssueCircuitDatumPolicy < ApplicationPolicy
  attr_reader :user, :issue_circuit_datum

  def initialize(user, issue_circuit_datum)
    @user = user
    @issue_circuit_datum = issue_circuit_datum
  end
end
