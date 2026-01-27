# frozen_string_literal: true

class AddLiftedByToUserBans < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:user_bans, :lifted_by_id)
      add_reference :user_bans, :lifted_by, foreign_key: { to_table: :users }, null: true
    end

    # Add FK for reports table now that it exists
    unless foreign_key_exists?(:user_bans, :reports)
      add_foreign_key :user_bans, :reports, column: :report_id, on_delete: :nullify
    end
  end
end
