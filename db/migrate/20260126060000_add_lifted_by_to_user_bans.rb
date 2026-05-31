# frozen_string_literal: true

class AddLiftedByToUserBans < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:user_bans, :lifted_by_id)
      add_reference :user_bans, :lifted_by, foreign_key: { to_table: :users, on_delete: :nullify }, null: true
    end
  end
end
