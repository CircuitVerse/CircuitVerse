# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Contests#close_contest", type: :request do
  let(:admin)   { create(:user, admin: true) }
  let(:contest) { create(:contest, status: :live, deadline: 1.minute.ago) }

  before do
    sign_in admin
    enable_contests!
  end

  it "marks the contest completed and redirects" do
    put close_contest_path(contest)

    expect(contest.reload.status).to eq("completed")
    expect(response).to redirect_to(contest_page_path(contest))
    expect(flash[:notice]).to match(/successfully ended/i)
  end
end
