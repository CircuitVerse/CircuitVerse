class AddSubmissionsCountToContests < ActiveRecord::Migration[8.0]
  def up
    add_column :contests, :submissions_count, :integer, default: 0, null: false

    Contest.reset_column_information
    Contest.find_each do |contest|
      Contest.reset_counters(contest.id, :submissions)
    end
  end

  def down
    remove_column :contests, :submissions_count
  end
end
