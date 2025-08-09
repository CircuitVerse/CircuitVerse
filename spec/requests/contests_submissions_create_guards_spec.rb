# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Contest submissions create guards", type: :request do
  let(:contest) { create(:contest, :live) }

  it "redirects when submitting a project the user does not own" do
    owner   = create(:user)
    thief   = create(:user)
    project = create(:project, author: owner)

    sign_in thief

    expect do
      post contest_submissions_path(contest),
           params: { submission: { project_id: project.id } }
    end.not_to change(Submission, :count)

    expect(response).to redirect_to(contest_path(contest))
    expect(flash[:alert]).to eq(I18n.t("contests.submissions.create.unauthorized_project"))
  end

  it "redirects when submitting a duplicate project to the same contest" do
    author  = create(:user)
    project = create(:project, author: author)
    create(:submission, contest: contest, project: project)

    sign_in author

    expect do
      post contest_submissions_path(contest),
           params: { submission: { project_id: project.id } }
    end.not_to change(Submission, :count)

    expect(response).to redirect_to(new_contest_submission_path(contest))
    expect(flash[:notice]).to eq(
      I18n.t("contests.submissions.create.duplicate_submission", contest_id: contest.id)
    )
  end
end
