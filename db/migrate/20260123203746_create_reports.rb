class CreateReports < ActiveRecord::Migration[8.0]
  def change
    create_table :reports do |t|
      t.references :reporter, null: false, foreign_key: true
      t.references :reported_user, null: false, foreign_key: true
      t.string :reason
      t.text :description
      t.string :status

      t.timestamps
    end
  end
end
