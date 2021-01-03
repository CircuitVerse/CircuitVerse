class AddGdpr < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :accepted_privacy_policy, :boolean, default: false
  end
end
