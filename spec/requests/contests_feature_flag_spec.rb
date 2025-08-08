# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Contest feature-flag", type: :request do
  around do |example|
    flipper_disable(:contests)
    example.run
    flipper_enable(:contests)
  end

  it "guards a protected route (admin list)" do
    admin = create(:user, admin: true)
    sign_in admin

    get admin_contests_path

    expect(response).to redirect_to(root_path)
    expect(flash[:alert]).to eq(I18n.t("feature_not_available"))
  end

  it "guards the public contests#index" do
    get contests_path

    expect(response).to redirect_to(root_path)
    expect(flash[:alert]).to eq(I18n.t("feature_not_available"))
  end

  it "guards submissions#new" do
    user = create(:user)
    sign_in user
    contest = create(:contest)

    get new_contest_submission_path(contest)

    expect(response).to redirect_to(root_path)
    expect(flash[:alert]).to eq(I18n.t("feature_not_available"))
  end

  it "guards votes#create" do
    user      = create(:user)
    author    = create(:user)
    project   = create(:project, author: author)
    contest   = create(:contest)
    submission = create(:submission, contest: contest, project: project)

    sign_in user

    post contest_submission_votes_path(contest, submission)

    expect(response).to redirect_to(root_path)
    expect(flash[:alert]).to eq(I18n.t("feature_not_available"))
  end
end
