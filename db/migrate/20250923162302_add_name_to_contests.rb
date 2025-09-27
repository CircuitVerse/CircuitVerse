class AddNameToContests < ActiveRecord::Migration[8.0]
  

  def up
    add_column :contests, :name, :string

    
    local_contest = Class.new(ActiveRecord::Base) do
      self.table_name = 'contests'
    end

    # Backfill names for existing contests
    local_contest.all.each do |contest|
      
      contest.update_columns(name: "Contest ##{contest.id}")
    end
  end

  def down
    remove_column :contests, :name
  end
end
