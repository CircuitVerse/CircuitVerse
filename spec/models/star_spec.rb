# frozen_string_literal: true

require "rails_helper"

RSpec.describe Star, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:project).counter_cache(true) }
  end

  describe "callbacks" do
    let(:author) { FactoryBot.create(:user) }
    let(:user) { FactoryBot.create(:user) }
    let(:project) { FactoryBot.create(:project, author: author) }

    it "increments the project's star count" do
      expect {
        Star.create!(user: user, project: project)
      }.to change { project.reload.stars_count }.by(1)
    end

    describe "#notify_recipient" do
      it "sends a notification when a different user stars the project" do
        expect(StarNotification).to receive(:with)
          .with(hash_including(user: user, project: project))
          .at_least(:once)
          .and_call_original
        
        star = Star.create!(user: user, project: project)
        
        if ActiveRecord::Base.connection.transaction_open?
          star.run_callbacks(:commit)
        end
      end

      it "does not send a notification when the author stars their own project" do
        expect(StarNotification).not_to receive(:with)
        
        star = Star.create!(user: author, project: project)
        
        if ActiveRecord::Base.connection.transaction_open?
          star.run_callbacks(:commit)
        end
      end
    end
  end
end