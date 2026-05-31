class AddOrganizationIdToGroups < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_reference :groups, :organization,
                  null: true,
                  foreign_key: false,
                  index: { algorithm: :concurrently }
  end
end
