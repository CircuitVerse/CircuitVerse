class CreateFcms < ActiveRecord::Migration[6.0]
  def change
    create_table :fcms do |t|
      t.string :token, null: false
      t.references :user, foreign_key: true, unique: true, on_delete: :cascade

      t.timestamps
    end
  end
end
