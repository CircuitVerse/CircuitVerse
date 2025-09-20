# frozen_string_literal: true

class AddDeadlineConstraintToContests < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    safety_assured { change_column_null :contests, :deadline, false }

    change_column_default :contests, :status, from: nil, to: 0

    add_index :contests,
              :status,
              unique: true,
              name:   "index_contests_on_status_live_unique",
              where:  "status = 0",
              algorithm: :concurrently
  end
end
