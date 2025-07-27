# frozen_string_literal: true

class AddDeadlineConstraintToContests < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_check_constraint :contests,
                         "deadline IS NOT NULL",
                         name: "chk_contests_deadline_not_null",
                         validate: false

    change_column_default :contests, :status, from: nil, to: 0

    add_index :contests,
              :status,
              unique: true,
              name:   "index_contests_on_status_live_unique",
              where:  "status = 0",
              algorithm: :concurrently
  end
end
