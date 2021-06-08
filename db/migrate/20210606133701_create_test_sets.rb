class CreateTestSets < ActiveRecord::Migration[6.0]
  def change
    create_table :test_sets do |t|
      t.string :title
      t.string :testset_access_type
      t.text :description
      t.text :data
      t.references :author
      t.references :forked_testset

      t.timestamps
    end
    add_foreign_key :test_sets, :users, column: :author_id, validate: false
    add_foreign_key :test_sets, :test_sets, column: :forked_testset_id, validate: false
  end
end
