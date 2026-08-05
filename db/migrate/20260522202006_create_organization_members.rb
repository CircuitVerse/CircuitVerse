class CreateOrganizationMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :organization_members do |t|
      t.references :organization, null: false, foreign_key: { on_delete: :cascade }
      t.references :user,         null: false, foreign_key: { on_delete: :cascade }
      t.integer    :role,         null: false, default: 2
      t.timestamps null: false
    end

    add_index :organization_members, [:organization_id, :user_id],
              unique: true,
              name: "index_organization_members_on_org_and_user_unique"
  end
end