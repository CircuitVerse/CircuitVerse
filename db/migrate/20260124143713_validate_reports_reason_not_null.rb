class ValidateReportsReasonNotNull < ActiveRecord::Migration[8.0]
  def up
    validate_check_constraint :reports, name: "reports_reason_null"
    change_column_null :reports, :reason, false
    remove_check_constraint :reports, name: "reports_reason_null"
  end

  def down
    add_check_constraint :reports, "reason IS NOT NULL",
                         name: "reports_reason_null",
                         validate: false
    change_column_null :reports, :reason, true
  end
end

