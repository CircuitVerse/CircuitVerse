# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Contests#destroy guards", type: :request do
  let(:admin) { create(:user, admin: true) }

  before do
    sign_in admin
    enable_contests!
  end

  it "does not delete a live contest" do
    contest = create(:contest, status: :live)

    expect do
      delete admin_contest_path(contest)
    end.not_to change(Contest, :count)

    expect(response).to redirect_to(admin_contests_path)
    expect(flash[:alert]).to match(/Only completed contests can be deleted/i)
  end
end
