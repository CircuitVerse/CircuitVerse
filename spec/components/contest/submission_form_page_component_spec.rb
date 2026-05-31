# frozen_string_literal: true

require "rails_helper"

RSpec.describe Contest::SubmissionFormPageComponent, type: :component do
  it "lists a project" do
    user    = create(:user)
    project = create(:project, author: user)
    contest = create(:contest, :live)
    render_inline(described_class.new(contest: contest,
                                      projects: [project],
                                      submission: contest.submissions.new,
                                      notice: nil))
    expect(page).to have_css(".submission-card[data-project-id='#{project.id}']")
  end
end
