class CreateSubmissions < ActiveRecord::Migration[7.0]
  def change
    create_table :submissions do |t|
      t.references :contest, foreign_key: true
      t.references :project, foreign_key: true
      t.bigint :submission_votes_count, default: 0
      t.boolean :winner, default: false
      t.timestamps
    end
  end
end
