class BackfillCounterCaches < ActiveRecord::Migration[7.0]
  def up
    # Backfill stars_count for projects
    Project.find_each do |project|
      Project.reset_counters(project.id, :stars)
    end

    # Backfill projects_count for users
    User.find_each do |user|
      User.reset_counters(user.id, :projects)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Counter cache backfills cannot be reversed safely"
  end
end
