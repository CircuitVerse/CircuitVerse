# frozen_string_literal: true

class CreateGradingResults < ActiveRecord::Migration[8.1]
  def change
    create_table :grading_results do |t|
      t.references :project, null: false, foreign_key: true
      t.jsonb :suite_snapshot, null: false, default: {}
      t.jsonb :breakdown, null: false, default: []
      t.decimal :score, precision: 5, scale: 2

      t.timestamps
    end
  end
end
