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
    get admin_contests_path
    expect(response).to redirect_to(root_path)
    expect(flash[:alert]).to eq("Contest feature is not available.")
  end
end
