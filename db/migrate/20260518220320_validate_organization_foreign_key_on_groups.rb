class ValidateOrganizationForeignKeyOnGroups < ActiveRecord::Migration[8.0]
  def change
    validate_foreign_key :groups, :organizations
  end
end