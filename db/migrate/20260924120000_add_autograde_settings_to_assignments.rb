# frozen_string_literal: true

class AddAutogradeSettingsToAssignments < ActiveRecord::Migration[8.1]
  def change
    add_column :assignments, :partial_credit, :boolean, default: false
    add_column :assignments, :max_attempts, :integer
    add_column :assignments, :reveal_test_cases, :boolean, default: false
  end
end
