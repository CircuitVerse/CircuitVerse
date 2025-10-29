# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Contests#create guard", type: :request do
  let(:admin) { create(:user, admin: true) }

  before { sign_in admin; enable_contests! }

  it "redirects when another live contest exists" do
    create(:contest, status: :live)

    post admin_contests_path

    expect(response).to redirect_to(admin_contests_path)
    expect(flash[:notice]).to match(/Concurrent contests are not allowed/i)
  end
end
