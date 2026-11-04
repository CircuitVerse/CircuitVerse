# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::ContestsController#index", type: :request do
  it "renders successfully for admins" do
    admin = create(:user, admin: true)
    sign_in admin

    get admin_contests_path

    expect(response).to have_http_status(:ok)
  end

  it "points the close and edit buttons at the contest's own modals" do
    sign_in create(:user, admin: true)
    contest = create(:contest)

    get admin_contests_path

    %W[close-contest-confirmation-modal-#{contest.id} update-contest-modal-#{contest.id}].each do |modal_id|
      expect(response.body).to include(%(data-bs-target="##{modal_id}"))
      expect(response.body).to include(%(id="#{modal_id}"))
    end
  end
end
