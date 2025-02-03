# This migration comes from commontator (originally 0)
class InstallCommontator < ActiveRecord::Migration[5.0]
  def change
    create_table :commontator_comments do |t|
      t.string   :creator_type
      t.integer  :creator_id
      t.string   :editor_type
      t.integer  :editor_id
      t.integer  :thread_id, null: false
      t.text     :body, null: false
      t.datetime :deleted_at

      t.integer :cached_votes_up, default: 0
      t.integer :cached_votes_down, default: 0

      t.timestamps null: false
    end

    add_index :commontator_comments, [:creator_id, :creator_type, :thread_id],
              name: 'index_commontator_comments_on_c_id_and_c_type_and_t_id'
    add_index :commontator_comments, [:thread_id, :created_at]

    add_index  :commontator_comments, :cached_votes_up
    add_index  :commontator_comments, :cached_votes_down

    create_table :commontator_subscriptions do |t|
      t.string   :subscriber_type, null: false
      t.integer  :subscriber_id, null: false
      t.integer  :thread_id, null: false

      t.timestamps null: false
    end

    add_index :commontator_subscriptions, [:subscriber_id, :subscriber_type, :thread_id],
              unique: true,
              name: 'index_commontator_subscriptions_on_s_id_and_s_type_and_t_id'
    add_index :commontator_subscriptions, :thread_id

    create_table :commontator_threads do |t|
      t.string   :commontable_type
      t.integer  :commontable_id
      t.datetime :closed_at
      t.string   :closer_type
      t.integer  :closer_id

      t.timestamps null: false
    end

    add_index :commontator_threads, [:commontable_id, :commontable_type],
              unique: true,
              name: 'index_commontator_threads_on_c_id_and_c_type'
  end
end
