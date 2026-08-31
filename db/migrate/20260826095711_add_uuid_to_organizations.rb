class AddUuidToOrganizations < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_column :organizations, :uuid, :uuid, default: -> { "gen_random_uuid()" }, null: false
    add_index :organizations, :uuid, unique: true, algorithm: :concurrently
  end
end
