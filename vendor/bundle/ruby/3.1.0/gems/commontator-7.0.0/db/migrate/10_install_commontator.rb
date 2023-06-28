class InstallCommontator < ActiveRecord::Migration[6.0]
  def change
    create_table :commontator_threads do |t|
      t.references :commontable,
                   polymorphic: true,
                   index: { unique: true, name: 'index_commontator_threads_on_c_id_and_c_type' }
      t.references :closer, polymorphic: true

      t.datetime :closed_at

      t.timestamps
    end

    create_table :commontator_comments do |t|
      t.references :thread, null: false, index: false, foreign_key: {
        to_table: :commontator_threads, on_update: :cascade, on_delete: :cascade
      }
      t.references :creator, polymorphic: true, null: false, index: false
      t.references :editor, polymorphic: true

      t.text     :body, null: false
      t.datetime :deleted_at

      t.integer :cached_votes_up, default: 0, index: true
      t.integer :cached_votes_down, default: 0, index: true

      t.timestamps
    end

    add_index :commontator_comments, [ :creator_id, :creator_type, :thread_id ],
              name: 'index_commontator_comments_on_c_id_and_c_type_and_t_id'
    add_index :commontator_comments, [ :thread_id, :created_at ]

    create_table :commontator_subscriptions do |t|
      t.references :thread, null: false, foreign_key: {
        to_table: :commontator_threads, on_update: :cascade, on_delete: :cascade
      }
      t.references :subscriber, polymorphic: true, null: false, index: false

      t.timestamps
    end

    add_index :commontator_subscriptions, [ :subscriber_id, :subscriber_type, :thread_id ],
              unique: true,
              name: 'index_commontator_subscriptions_on_s_id_and_s_type_and_t_id'
  end
end
