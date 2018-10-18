class RemoveAgeFromUser < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :age
  end
end
