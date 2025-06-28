# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Contests#close_contest edge-case", type: :request do
  let(:admin)   { create(:user, admin: true) }
  let(:contest) { create(:contest, status: :completed) }

  before { sign_in admin; enable_contests! }

  it "just redirects when the contest is already completed" do
    put close_contest_path(contest)

    expect(response).to redirect_to(contest_page_path(contest))
    expect(contest.reload.status).to eq("completed")
  end
end
