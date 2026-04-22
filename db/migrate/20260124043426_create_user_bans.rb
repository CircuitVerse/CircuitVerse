class CreateUserBans < ActiveRecord::Migration[8.0]
  def change
    create_table :user_bans do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :admin, foreign_key: { to_table: :users, on_delete: :nullify }
      t.references :report, foreign_key: { on_delete: :nullify } # Reports table created in earlier migration
      t.text :reason, null: false
      t.datetime :lifted_at # NULL = still active

      t.timestamps
    end

    add_index :user_bans, :user_id, unique: true, where: "lifted_at IS NULL", name: "idx_user_bans_one_active_per_user"
    add_index :user_bans, [:user_id, :lifted_at]
    add_index :user_bans, :admin_id unless index_exists?(:user_bans, :admin_id)
  end
end
