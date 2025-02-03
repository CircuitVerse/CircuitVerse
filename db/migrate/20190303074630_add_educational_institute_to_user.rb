class AddEducationalInstituteToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :educational_institute, :string
  end
end
