# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Contest feature-flag", type: :request do
  around do |example|
    sign_in create(:user)
    Flipper.disable(:contests)
    example.run
    Flipper.enable(:contests)
  end

  it "guards a protected route (admin list)" do
    get contests_admin_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("You are not authorized to do the requested operation")
  end
end
