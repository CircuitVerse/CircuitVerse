class CreateUserBans < ActiveRecord::Migration[8.0]
  def change
    create_table :user_bans do |t|
      t.references :user, null: false, foreign_key: true
      t.references :admin, null: false, foreign_key: { to_table: :users }
      t.references :report, foreign_key: false # Will add FK later when reports table exists
      t.text :reason, null: false
      t.datetime :lifted_at # NULL = still active

      t.timestamps
    end

    add_index :user_bans, [:user_id, :lifted_at] unless index_exists?(:user_bans, [:user_id, :lifted_at])
    add_index :user_bans, :admin_id unless index_exists?(:user_bans, :admin_id)
  end
end
