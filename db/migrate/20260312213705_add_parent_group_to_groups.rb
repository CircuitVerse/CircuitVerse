class AddParentGroupToGroups < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_reference :groups, :parent_group,
                  null: true,
                  index: { algorithm: :concurrently }
  end
end
