class CreateLtiAssignmentSubmissions < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    create_table :assignment_submissions do |t|
      t.references :assignment, null: false,
                   index: { algorithm: :concurrently }
      t.references :project,    null: false,
                   index: { algorithm: :concurrently }
      t.references :user,       null: false,
                   index: { algorithm: :concurrently }
      t.references :subgroup,   null: true,
                   index: { algorithm: :concurrently }
      t.integer    :status,     null: false, default: 0
      t.float      :score,      null: true
      t.datetime   :submitted_at
      t.timestamps
    end

    add_index :assignment_submissions,
              [:assignment_id, :user_id],
              unique: true,
              name: "index_submissions_unique_per_user",
              algorithm: :concurrently

    add_column :assignments, :submission_type,
               :integer, null: false, default: 0
  end
end
