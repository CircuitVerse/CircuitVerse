# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Contests#create", type: :request do
  let(:admin) { create(:user, admin: true) }

  before do
    sign_in admin
    enable_contests!
  end

  it "creates a new contest and redirects" do
    expect do
      post admin_contests_path,
           params: { contest: { deadline: 1.week.from_now.iso8601 } }
    end.to change(Contest, :count).by(1)

    new_contest = Contest.order(:created_at).last
    expect(response).to redirect_to(contest_path(new_contest))
    expect(flash[:notice]).to match(/successfully started/i)
  end
end
