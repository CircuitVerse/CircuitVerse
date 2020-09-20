class MultipleMentorsPerGroup < ActiveRecord::Migration[6.0]
  def change
    rename_column :groups, :mentor_id, :owner_id

    create_table :group_mentors do |t|
      t.references :group, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
