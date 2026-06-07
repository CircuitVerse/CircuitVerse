class CreateSubgroupInfrastructure < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    create_table :subgroups do |t|
      t.string     :name,     null: false
      t.references :group,    null: false,
                   foreign_key: true,
                   index: { algorithm: :concurrently }
      t.integer    :max_size, null: true
      t.timestamps
    end

    add_index :subgroups, [:group_id, :name],
              unique: true,
              name: "index_subgroups_unique_name_per_group",
              algorithm: :concurrently

    create_table :subgroup_members do |t|
      t.references :subgroup, null: false,
                   foreign_key: true,
                   index: { algorithm: :concurrently }
      t.references :user,     null: false,
                   foreign_key: true,
                   index: { algorithm: :concurrently }
      t.integer    :role,     null: false, default: 0
      t.timestamps
    end

    add_index :subgroup_members, [:subgroup_id, :user_id],
              unique: true,
              name: "index_subgroup_members_unique",
              algorithm: :concurrently
  end
end
