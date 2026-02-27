class AddSubmissionsCountToContests < ActiveRecord::Migration[8.0]
  def change
    add_column :contests, :submissions_count, :integer ,default: 0, null: false
  end
end
