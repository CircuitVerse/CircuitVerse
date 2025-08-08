# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::ContestsController#index", type: :request do
  before do
    flipper_enable(:contests)
  end

  it "renders successfully for admins" do
    admin = create(:user, admin: true)
    sign_in admin

    get admin_contests_path

    expect(response).to have_http_status(:ok)
  end
end
