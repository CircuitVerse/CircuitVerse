# frozen_string_literal: true

class AddParentGroupToGroups < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_reference :groups, :parent_group, foreign_key: false, index: { algorithm: :concurrently }
  end
end
