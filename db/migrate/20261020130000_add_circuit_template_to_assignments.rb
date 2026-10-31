# frozen_string_literal: true

class AddCircuitTemplateToAssignments < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_reference :assignments, :circuit_template, foreign_key: false, index: { algorithm: :concurrently }
  end
end
