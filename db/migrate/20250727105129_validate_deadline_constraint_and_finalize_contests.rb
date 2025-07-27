# frozen_string_literal: true

class ValidateDeadlineConstraintAndFinalizeContests < ActiveRecord::Migration[7.0]
  def change
    validate_check_constraint :contests, name: "chk_contests_deadline_not_null"

    change_column_null :contests, :deadline, false

    remove_check_constraint :contests, name: "chk_contests_deadline_not_null"
  end
end
