class UpdateReportsContractFields < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    # All operations are idempotent - safe to re-run
    unless constraint_exists?(:reports, "reports_reason_null")
      add_check_constraint :reports, "reason IS NOT NULL",
                           name: "reports_reason_null",
                           validate: false
    end

    change_column_default :reports, :status, from: nil, to: "open"

    add_index :reports, :status, algorithm: :concurrently, if_not_exists: true
    add_index :reports, [:reported_user_id, :created_at], algorithm: :concurrently, if_not_exists: true
  end

  private

  def constraint_exists?(table, name)
    connection.select_value(<<~SQL)
      SELECT 1 FROM pg_constraint WHERE conname = '#{name}'
    SQL
  end
end



