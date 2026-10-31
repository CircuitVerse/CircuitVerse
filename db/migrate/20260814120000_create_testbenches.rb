# frozen_string_literal: true

class CreateTestbenches < ActiveRecord::Migration[8.1]
  def change
    create_table :testbenches do |t|
      t.references :assignment, null: false, foreign_key: true, index: { unique: true }
      t.jsonb :data, null: false, default: {}

      t.timestamps
    end
  end
end
