# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::ContestsController#index", type: :request do
  around do |example|
    was_enabled = Flipper[:contests].enabled?
    flipper_enable(:contests)
    example.run
    was_enabled ? flipper_enable(:contests) : flipper_disable(:contests)
  end

  it "renders successfully for admins" do
    admin = create(:user, admin: true)
    sign_in admin

    get admin_contests_path

    expect(response).to have_http_status(:ok)
  end
end
