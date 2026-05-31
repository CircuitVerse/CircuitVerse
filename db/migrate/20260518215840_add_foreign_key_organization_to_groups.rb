class AddForeignKeyOrganizationToGroups < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :groups, :organizations, validate: false, on_delete: :nullify
  end
end