# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContestDeadlineJob, type: :job do
  include ActiveJob::TestHelper

  it "closes overdue live contests" do
    contest = create(:contest, deadline: 1.hour.ago, status: :live)

    perform_enqueued_jobs do
      described_class.perform_later(contest.id)
    end

    expect(contest.reload).to be_completed
  end
end
