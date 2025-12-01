# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Contests#update (Deadline)", type: :request do
  let(:admin) { create(:user, admin: true) }
  let(:contest) { create(:contest, status: :live, deadline: 2.days.from_now, name: "Test Contest") }

  before { sign_in admin; enable_contests! }

  context "invalid date format" do
    it "redirects with alert when non-date string is submitted" do
      patch admin_contest_path(contest), params: { contest: { deadline: "not-a-date" } }
      expect(flash[:alert]).to match(/Invalid deadline format/)
      expect(response).to redirect_to(admin_contests_path)
      expect(contest.reload.deadline).to be_within(1.minute).of(2.days.from_now)
    end
  end

  context "past date submission" do
    it "rejects date in the past and redirects with an alert" do
      patch admin_contest_path(contest), params: {
        contest: { deadline: 1.day.ago.strftime("%Y-%m-%dT%H:%M") }
      }
      expect(flash[:alert]).to match(/Deadline must be in the future/)
      expect(response).to redirect_to(admin_contests_path)
      expect(contest.reload.deadline).to be_within(1.minute).of(2.days.from_now)
    end
  end

  context "successful update" do
    it "updates the deadline and redirects to admin index with success notice" do
      new_deadline = 1.week.from_now

      patch admin_contest_path(contest), params: {
        contest: { deadline: new_deadline.strftime("%Y-%m-%dT%H:%M") }
      }
      expect(response).to redirect_to(admin_contests_path)
      expect(flash[:notice]).to match(/successfully updated/)
      expect(contest.reload.deadline).to be_within(1.minute).of(new_deadline)
    end
  end

  context "save failure branch" do
    it "redirects with alert when update fails internally" do
      allow_any_instance_of(Contest).to receive(:update).and_return(false)

      patch admin_contest_path(contest), params: {
        contest: { deadline: 1.week.from_now.strftime("%Y-%m-%dT%H:%M") }
      }
      expect(response).to redirect_to(admin_contests_path)
      expect(flash[:alert]).to match(/Failed to update contest deadline/)
    end
  end
end
