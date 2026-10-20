# frozen_string_literal: true

class AddForeignKeyCircuitTemplateToAssignments < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :assignments, :projects, column: :circuit_template_id, on_delete: :nullify, validate: false
  end
end
