class AddSubscribedToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :subscribed, :boolean, default: true
  end
end
