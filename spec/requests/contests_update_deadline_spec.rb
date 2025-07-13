# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Contests#update", type: :request do
  let(:admin)   { create(:user, admin: true) }
  let(:contest) { create(:contest, status: :live, deadline: 2.days.from_now) }

  before { sign_in admin; enable_contests! }

  context "invalid date format" do
    it "redirects with alert" do
      patch admin_contest_path(contest), params: { contest: { deadline: "not-a-date" } }
      expect(flash[:alert]).to match(/Invalid deadline format/)
      expect(response).to redirect_to(admin_contests_path)
    end
  end

  context "past date" do
    it "rejects and redirects" do
      patch admin_contest_path(contest), params: { contest: { deadline: 1.day.ago.iso8601 } }
      expect(flash[:alert]).to match(/Deadline must be in the future/)
      expect(response).to redirect_to(admin_contests_path)
    end
  end

  context "successful update" do
    it "updates and redirects to page" do
      new_deadline = 1.week.from_now
      patch admin_contest_path(contest), params: { contest: { deadline: new_deadline.iso8601 } }
      expect(response).to redirect_to(contest_path(contest))
      expect(flash[:notice]).to match(/successfully updated/)
      expect(contest.reload.deadline.to_i).to eq(new_deadline.to_i)
    end
  end

  context "save failure branch" do
    it "renders admin with alert" do
      allow_any_instance_of(Contest).to receive(:update).and_return(false)
      patch admin_contest_path(contest), params: { contest: { deadline: 1.week.from_now.iso8601 } }
      expect(response).to redirect_to(admin_contests_path)
      expect(flash[:alert]).to match(/Failed to update/)
    end
  end
end
