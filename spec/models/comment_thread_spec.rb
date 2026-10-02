# frozen_string_literal: true

require "rails_helper"

RSpec.describe CommentThread, type: :model do
  let(:project) { FactoryBot.create(:project, project_access_type: "Public") }
  let(:thread) { project.comment_thread }

  describe "lifecycle" do
    it "auto-builds a thread for persisted projects" do
      expect(thread).to be_persisted
      expect(thread.commontable).to eq(project)
    end

    it "closes" do
      user = FactoryBot.create(:user)
      expect(thread.is_closed?).to be false
      expect(thread.close(user)).to be_truthy
      expect(thread.is_closed?).to be true
      expect(thread.close(user)).to be false
    end

    it "reopens" do
      thread.close(FactoryBot.create(:user))
      expect(thread.reopen).to be_truthy
      expect(thread.is_closed?).to be false
      expect(thread.reopen).to be false
    end
  end

  describe "subscriptions" do
    it "subscribes and unsubscribes" do
      user = FactoryBot.create(:user)
      expect(thread.subscribe(user)).to be_truthy
      expect(thread.subscribe(user)).to be false
      expect(thread.subscribers).to include(user)
      expect(thread.unsubscribe(user)).to be_truthy
      expect(thread.unsubscribe(user)).to be false
    end

    it "rejects nil subscribers" do
      expect(thread.subscribe(nil)).to be false
    end
  end

  describe "permissions" do
    it "is readable by anyone when the project is public" do
      expect(thread.can_be_read_by?(nil)).to be true
      expect(thread.can_be_read_by?(FactoryBot.create(:user))).to be true
    end

    it "restricts private projects to viewers" do
      private_project = FactoryBot.create(:project, project_access_type: "Private")
      private_thread = private_project.comment_thread
      author = private_project.author
      expect(private_thread.can_be_read_by?(nil)).to be false
      expect(private_thread.can_be_read_by?(FactoryBot.create(:user))).to be false
      expect(private_thread.can_be_read_by?(author)).to be true
    end

    it "is editable only by admins" do
      expect(thread.can_be_edited_by?(FactoryBot.create(:user))).to be false
      expect(thread.can_be_edited_by?(FactoryBot.create(:user, :admin))).to be true
      expect(thread.can_be_edited_by?(nil)).to be false
    end

    it "allows subscriptions only on open readable threads" do
      user = FactoryBot.create(:user)
      expect(thread.can_subscribe?(user)).to be true
      expect(thread.can_subscribe?(nil)).to be false
      thread.close(FactoryBot.create(:user, :admin))
      expect(thread.can_subscribe?(user)).to be false
    end
  end
end
