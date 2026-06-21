class BackfillContestSubmissionsCount < ActiveRecord::Migration[7.0]
  def up
    execute "LOCK TABLE submissions IN SHARE MODE"

    execute <<~SQL.squish
      UPDATE contests
      SET submissions_count = counts.submission_count
      FROM (
        SELECT contest_id, COUNT(*) AS submission_count
        FROM submissions
        GROUP BY contest_id
      ) AS counts
      WHERE counts.contest_id = contests.id
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Counter cache backfills cannot be reversed safely"
  end
end
