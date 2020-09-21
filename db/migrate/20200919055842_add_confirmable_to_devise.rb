class AddConfirmableToDevise < ActiveRecord::Migration[6.0]
  # Note: You can't use change, as User.update_all will fail in the down migration
  def up
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email, :string # Only if using reconfirmable
    add_index :users, :confirmation_token, unique: true

    # Send confirmation email to all existing users
    User.find_each { |user| user.send_confirmation_instructions }
    
    # Set all current email subscriptions to false
    User.update_all subscribed: false
    # Change default email subscriptions to false
    change_column_default :users, :subscribed, false
  end

  def down
    remove_index :users, :confirmation_token
    remove_columns :users, :confirmation_token, :confirmed_at, :confirmation_sent_at
    remove_columns :users, :unconfirmed_email # Only if using reconfirmable
    change_column_default :users, :subscribed, true
  end
end
