# frozen_string_literal: true

class CreateIssues < ActiveRecord::Migration[7.0]
  def change
    create_table :issues do |t|
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.references :project, null: true, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :state, null: false, default: 'open'
      t.string :github_url
      t.bigint :github_id
      t.datetime :closed_at

      t.timestamps
    end

    add_index :issues, :github_id, unique: true
    add_index :issues, :state
    add_index :issues, :created_at
    add_index :issues, :author_id
  end
end
