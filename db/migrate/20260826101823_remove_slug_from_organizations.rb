class RemoveSlugFromOrganizations < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      remove_index :organizations, name: "index_organizations_on_slug"
      remove_check_constraint :organizations, name: "organizations_slug_not_blank"
      remove_column :organizations, :slug
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Slug data cannot be restored once removed"
  end
end
