class CreateDummyUsers < ActiveRecord::Migration[5.0]
  def change
    create_table "dummy_users" do |t|
      t.timestamps null: false
    end
  end
end
