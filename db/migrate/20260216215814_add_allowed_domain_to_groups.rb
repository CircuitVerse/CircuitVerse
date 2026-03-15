class AddAllowedDomainToGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :groups, :allowed_domain, :string
  end
end
