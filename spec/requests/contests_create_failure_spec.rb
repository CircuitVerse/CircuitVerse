# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Contests#create failure path", type: :request do
  let(:admin) { create(:user, admin: true) }

  before { sign_in admin; enable_contests! }

  it "re-renders the admin page with 422 when the save fails" do
    allow_any_instance_of(Contest).to receive(:save).and_return(false)

    post new_contest_path, params: { contest: {} }

    expect(response).to have_http_status(:unprocessable_entity)

    expect(response.body).to include(I18n.t("contest.heading"))
  end
end
