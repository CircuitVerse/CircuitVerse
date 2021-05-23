class AddFieldsToGroups < ActiveRecord::Migration[6.0]
  def change
    add_column :groups, :lmstype, :string
  end
end
