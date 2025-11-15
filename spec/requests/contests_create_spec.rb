# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Contests#create", type: :request do
  let(:admin) { create(:user, admin: true) }

  before do
    login_as(admin, scope: :user)
    enable_contests!

    allow(ContestScheduler).to receive(:call)
  end

  context "when no custom name is provided" do
    it "creates a contest and relies on the model to auto-generate a name" do
      params = { contest: { deadline: 1.week.from_now.strftime("%Y-%m-%dT%H:%M") } }

      expect do
        post admin_contests_path, params: params
      end.to change(Contest, :count).by(1)

      new_contest = Contest.order(:created_at).last
      expect(new_contest.name).to start_with("Contest #")

      expect(response).to redirect_to(contest_path(new_contest))
      expect(flash[:notice]).to match(/successfully started/i)
    end
  end

  context "when a custom name is provided" do
    it "creates a new contest with the custom name" do
      custom_name = "My Awesome Custom Circuit Challenge"
      params = {
        contest: {
          name: custom_name,
          deadline: 1.week.from_now.strftime("%Y-%m-%dT%H:%M")
        }
      }

      expect do
        post admin_contests_path, params: params
      end.to change(Contest, :count).by(1)
      new_contest = Contest.order(:created_at).last
      expect(new_contest.name).to eq(custom_name)
      expect(response).to redirect_to(contest_path(new_contest))
      expect(flash[:notice]).to match(/successfully started/i)
    end
  end
end
