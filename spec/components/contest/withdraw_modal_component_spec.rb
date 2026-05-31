# frozen_string_literal: true

require "rails_helper"

RSpec.describe Contest::WithdrawModalComponent, type: :component do
  it "renders heading and button" do
    contest    = create(:contest)
    submission = create(:submission, contest: contest)

    render_inline(described_class.new(contest: contest, submission: submission))

    expect(page).to have_css("#withdraw-submission-button")
    expect(page).to have_text("Withdraw Submission")
  end
end
