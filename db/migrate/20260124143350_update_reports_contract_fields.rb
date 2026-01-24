class UpdateReportsContractFields < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_check_constraint :reports, "reason IS NOT NULL",
                         name: "reports_reason_null",
                         validate: false

    change_column_default :reports, :status, from: nil, to: "open"

    add_index :reports, :status, algorithm: :concurrently
    add_index :reports, [:reported_user_id, :created_at], algorithm: :concurrently
  end
end



