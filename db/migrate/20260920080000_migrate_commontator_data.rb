# frozen_string_literal: true

# Copies commontator threads/comments/subscriptions (including nested replies,
# which are flattened) into the homegrown comments domain, preserving IDs so
# API routes and URLs keep working. Votes are retargeted at the new Comment
# model. Safe to re-run: rows with an already-migrated ID are skipped.
class MigrateCommontatorData < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
    say_with_time "Migrating commontator threads" do
      execute(<<~SQL.squish)
        INSERT INTO comment_threads
          (id, closed_at, closer_id, closer_type, commontable_id, commontable_type,
           created_at, updated_at)
        SELECT id, closed_at, closer_id, closer_type, commontable_id, commontable_type,
           created_at, updated_at
        FROM commontator_threads
        ON CONFLICT (id) DO NOTHING
      SQL
    end

    say_with_time "Migrating commontator comments" do
      execute(<<~SQL.squish)
        INSERT INTO comments
          (id, body, cached_votes_up, cached_votes_down, creator_id, creator_type,
           deleted_at, editor_id, editor_type, thread_id, created_at, updated_at)
        SELECT id, body, cached_votes_up, cached_votes_down, creator_id, creator_type,
           deleted_at, editor_id, editor_type, thread_id, created_at, updated_at
        FROM commontator_comments
        ON CONFLICT (id) DO NOTHING
      SQL
    end

    say_with_time "Migrating commontator subscriptions" do
      execute(<<~SQL.squish)
        INSERT INTO comment_subscriptions
          (id, subscriber_id, subscriber_type, thread_id, created_at, updated_at)
        SELECT id, subscriber_id, subscriber_type, thread_id, created_at, updated_at
        FROM commontator_subscriptions
        ON CONFLICT (id) DO NOTHING
      SQL
    end

    say_with_time "Retargeting comment votes" do
      execute(<<~SQL.squish)
        UPDATE votes SET votable_type = 'Comment'
        WHERE votable_type = 'Commontator::Comment'
      SQL
    end

    %w[comment_threads comments comment_subscriptions].each do |table|
      say_with_time "Resetting #{table} primary key sequence" do
        execute(<<~SQL.squish)
          SELECT setval(pg_get_serial_sequence('#{table}', 'id'),
                        COALESCE((SELECT MAX(id) FROM #{table}), 1))
        SQL
      end
    end
    end
  end

  def down
    safety_assured do
      execute("UPDATE votes SET votable_type = 'Commontator::Comment' WHERE votable_type = 'Comment'")
    end
    CommentSubscription.delete_all
    Comment.delete_all
    CommentThread.delete_all
  end
end
