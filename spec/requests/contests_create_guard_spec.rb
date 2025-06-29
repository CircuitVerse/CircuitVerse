# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Contests#create guard", type: :request do
  let(:admin) { create(:user, admin: true) }

  before { sign_in admin; enable_contests! }

  it "redirects when another live contest exists" do
    create(:contest, status: :live)

    post new_contest_path

    expect(response).to redirect_to(contests_admin_path)
    expect(flash[:notice]).to match(/Concurrent contests are not allowed/i)
  end
end
