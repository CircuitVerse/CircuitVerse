# frozen_string_literal: true

require "rails_helper"

require_relative "../../db/migrate/20260920080000_migrate_commontator_data"

RSpec.describe MigrateCommontatorData do
  let(:user) { FactoryBot.create(:user) }
  let(:project) { FactoryBot.create(:project, project_access_type: "Public") }

  # NOTE: raw SQL fixtures: Project/User no longer carry commontator's
  # macros, so its inverse detection (inverse_of: :commontator_thread)
  # cannot resolve through ActiveRecord anymore.
  def seed_commontator!
    conn = ActiveRecord::Base.connection
    # Factories may auto-create a commontator thread for the project (via
    # acts_as_commontable autosave on eras where the macros are present), so
    # clear project rows first to keep counts and IDs deterministic.
    conn.execute(<<~SQL.squish)
      DELETE FROM commontator_subscriptions WHERE thread_id IN (
        SELECT id FROM commontator_threads
        WHERE commontable_id = #{project.id} AND commontable_type = 'Project')
    SQL
    conn.execute(<<~SQL.squish)
      DELETE FROM commontator_comments WHERE thread_id IN (
        SELECT id FROM commontator_threads
        WHERE commontable_id = #{project.id} AND commontable_type = 'Project')
    SQL
    conn.execute(<<~SQL.squish)
      DELETE FROM commontator_threads
      WHERE commontable_id = #{project.id} AND commontable_type = 'Project'
    SQL
    thread_id = conn.select_value(<<~SQL.squish)
      INSERT INTO commontator_threads
        (commontable_id, commontable_type, created_at, updated_at)
      VALUES (#{project.id}, 'Project', NOW(), NOW()) RETURNING id
    SQL
    parent_id = conn.select_value(<<~SQL.squish)
      INSERT INTO commontator_comments
        (thread_id, creator_id, creator_type, body, cached_votes_up,
         cached_votes_down, created_at, updated_at)
      VALUES (#{thread_id}, #{user.id}, 'User', 'parent', 0, 0, NOW(), NOW())
      RETURNING id
    SQL
    reply_id = conn.select_value(<<~SQL.squish)
      INSERT INTO commontator_comments
        (thread_id, creator_id, creator_type, body, parent_id, deleted_at,
         editor_id, editor_type, created_at, updated_at)
      VALUES (#{thread_id}, #{user.id}, 'User', 'reply', #{parent_id}, NOW(),
              #{user.id}, 'User', NOW(), NOW())
      RETURNING id
    SQL
    conn.execute(<<~SQL.squish)
      INSERT INTO commontator_subscriptions
        (thread_id, subscriber_id, subscriber_type, created_at, updated_at)
      VALUES (#{thread_id}, #{user.id}, 'User', NOW(), NOW())
    SQL
    voter = FactoryBot.create(:user)
    # Raw vote row (acts_as_votable): the gem is gone, so seed exactly what
    # commontator would have stored, including the cached counter.
    conn.execute(<<~SQL.squish)
      INSERT INTO votes
        (votable_id, votable_type, voter_id, voter_type, vote_flag,
         created_at, updated_at)
      VALUES (#{parent_id}, 'Commontator::Comment', #{voter.id}, 'User', TRUE,
              NOW(), NOW())
    SQL
    conn.execute(<<~SQL.squish)
      UPDATE commontator_comments SET cached_votes_up = 1 WHERE id = #{parent_id}
    SQL
    { thread_id: thread_id, parent_id: parent_id, reply_id: reply_id, voter: voter }
  end

  it "copies threads with stable IDs" do
    ids = seed_commontator!
    described_class.new.up

    expect(CommentThread.count).to eq(1)
    expect(CommentThread.find(ids[:thread_id]).commontable).to eq(project)
  end

  it "copies comments with bodies, creators and deleted flags" do
    ids = seed_commontator!
    described_class.new.up

    expect(Comment.count).to eq(2)
    parent = Comment.find(ids[:parent_id])
    expect(parent.body).to eq("parent")
    expect(parent.creator).to eq(user)
    expect(Comment.find(ids[:reply_id]).is_deleted?).to be true
  end

  it "copies subscriptions and votes" do
    ids = seed_commontator!
    described_class.new.up

    new_thread = CommentThread.find(ids[:thread_id])
    expect(CommentSubscription.count).to eq(1)
    expect(new_thread.subscribers).to include(user)
    expect(Comment.find(ids[:parent_id]).cached_votes_up).to eq(1)
    vote = ActsAsVotable::Vote.find_by(votable_id: ids[:parent_id])
    expect(vote.votable_type).to eq("Comment")
  end

  it "reverses the migration on down" do
    ids = seed_commontator!
    described_class.new.up
    vote = ActsAsVotable::Vote.find_by(votable_id: ids[:parent_id])

    described_class.new.down

    expect(CommentThread.count).to eq(0)
    expect(Comment.count).to eq(0)
    expect(CommentSubscription.count).to eq(0)
    expect(vote.reload.votable_type).to eq("Commontator::Comment")
  end
end
