# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Contests#update", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:admin)   { create(:user, admin: true) }
  let(:contest) { create(:contest, status: :live, deadline: 1.minute.from_now) }

  before do
    sign_in admin
    enable_contests!
  end

  it "marks the contest completed and redirects" do
    travel_to 2.minutes.from_now do
      patch admin_contest_path(contest), params: { contest: { status: :completed } }
    end

    expect(contest.reload.status).to eq("completed")
    expect(response).to redirect_to(contest_path(contest))
    expect(flash[:notice]).to match(/successfully ended/i)
  end
end
