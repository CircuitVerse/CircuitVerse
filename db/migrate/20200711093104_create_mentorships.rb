class CreateMentorships < ActiveRecord::Migration[6.0]
  def change
    create_table :mentorships do |t|
      t.references :user, foreign_key: true
      t.references :group, foreign_key: true

      t.timestamps
    end
  end
end
