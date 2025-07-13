# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Contests::Submissions#create", type: :request do
  let(:user)    { create(:user) }
  let(:contest) { create(:contest, status: :live) }
  let(:project) { create(:project, author: user) }

  before do
    sign_in user
    enable_contests!
  end

  it "allows the owner to submit and redirects" do
    expect do
      post contest_submissions_path(contest),
           params: { submission: { project_id: project.id,
                                   description: "My entry" } }
    end.to change(Submission, :count).by(1)

    expect(response).to redirect_to(contest_path(contest))
    expect(flash[:notice]).to match("Submission was successfully added.")
  end

  it "rejects someone else’s project" do
    other = create(:user)
    sign_in other

    post contest_submissions_path(contest),
         params: { submission: { project_id: project.id } }

    expect(response).to redirect_to(contest_path(contest))
    expect(flash[:alert]).to match("You can't submit someone else’s project.")
  end
end
