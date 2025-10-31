class AddNameToContests < ActiveRecord::Migration[8.0]
  def up
    # 1. Add the column to the database
    add_column :contests, :name, :string
    
    # 2. Define a local model class for safe data manipulation
    # This prevents issues if the Contest model changes in the future
    local_contest = Class.new(ActiveRecord::Base) do
      self.table_name = 'contests'
    end

    # 3. Backfill names for existing contests
    # Assigns a unique name based on the ID for all existing records
    local_contest.all.each do |contest|
      contest.update_columns(name: "Contest ##{contest.id}")
    end
  end

  def down
    # Remove the column when rolling back the migration
    remove_column :contests, :name
  end
end