class AddSocialMediaToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :instagram, :string
    add_column :users, :twitter, :string
    add_column :users, :linkedin, :string
    add_column :users, :github, :string
  end
end
