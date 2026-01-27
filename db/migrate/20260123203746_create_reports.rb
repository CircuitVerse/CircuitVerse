class CreateReports < ActiveRecord::Migration[8.0]
  def change
    create_table :reports do |t|
      t.references :reporter, foreign_key: { to_table: :users }, null: false
      t.references :reported_user, foreign_key: { to_table: :users }, null: false
      t.string :reason, null: false
      t.text :description
      t.string :status, null: false, default: "open"

      t.timestamps
    end

    add_index :reports, :status
    add_index :reports, [:reported_user_id, :created_at]
  end
end


