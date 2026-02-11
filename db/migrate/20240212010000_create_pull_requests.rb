# frozen_string_literal: true

class CreatePullRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :pull_requests do |t|
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.references :project, null: true, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :state, null: false, default: 'open'
      t.string :github_url
      t.bigint :github_id
      t.datetime :merged_at
      t.datetime :closed_at

      t.timestamps
    end

    add_index :pull_requests, :github_id, unique: true
    add_index :pull_requests, :state
    add_index :pull_requests, :created_at
    add_index :pull_requests, :author_id
  end
end
