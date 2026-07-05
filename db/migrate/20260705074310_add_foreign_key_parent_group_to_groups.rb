# frozen_string_literal: true

class AddForeignKeyParentGroupToGroups < ActiveRecord::Migration[8.1]
  def change
    # New column, all values NULL: validate: false is safe and avoids
    # blocking writes (matches 20260518215840 for the organization FK).
    add_foreign_key :groups, :groups, column: :parent_group_id, validate: false
  end
end
