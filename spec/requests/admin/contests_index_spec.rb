# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::ContestsController#index", type: :request do
  it "renders successfully for admins" do
    admin = create(:user, admin: true)
    sign_in admin

    get admin_contests_path

    expect(response).to have_http_status(:ok)
  end

  it "renders close and update modal targets matching contest IDs" do
    admin = create(:user, admin: true)
    contest = create(:contest, status: :live, deadline: 2.days.from_now)
    sign_in admin

    get admin_contests_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("data-bs-target=\"#close-contest-confirmation-modal-#{contest.id}\"")
    expect(response.body).to include("data-bs-target=\"#update-contest-modal-#{contest.id}\"")
  end
end
