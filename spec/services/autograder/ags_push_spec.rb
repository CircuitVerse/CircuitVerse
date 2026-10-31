# frozen_string_literal: true

require "rails_helper"

RSpec.describe Autograder::AgsPush do
  let(:link) { FactoryBot.create(:lti_resource_link) }
  let(:group) { FactoryBot.create(:group, primary_mentor: FactoryBot.create(:user)) }
  let(:assignment) { FactoryBot.create(:assignment, group: group, lti_resource_link: link) }
  let(:author) { FactoryBot.create(:user, lti_sub: "lms-user-1") }
  let(:project) { FactoryBot.create(:project, author: author, assignment: assignment) }

  describe ".call" do
    it "publishes the clamped score to the line item" do
      allow(Lti::AccessToken).to receive(:fetch).and_return("tok-1")
      allow(Lti::Score).to receive(:publish)

      described_class.call(project: project, score: 150)

      expect(Lti::Score).to have_received(:publish)
        .with(link.lineitem_url, "tok-1", user_id: "lms-user-1", score_given: 100, score_maximum: 100)
    end

    it "does nothing when the assignment has no resource link" do
      assignment.update!(lti_resource_link: nil)
      allow(Lti::AccessToken).to receive(:fetch)

      described_class.call(project: project, score: 80)

      expect(Lti::AccessToken).not_to have_received(:fetch)
    end

    it "does nothing when the author has no LTI subject" do
      author.update!(lti_sub: nil)
      allow(Lti::AccessToken).to receive(:fetch)

      described_class.call(project: project, score: 80)

      expect(Lti::AccessToken).not_to have_received(:fetch)
    end

    it "swallows a publish failure" do
      allow(Lti::AccessToken).to receive(:fetch).and_return("tok-1")
      allow(Lti::Score).to receive(:publish).and_raise(Lti::Score::Error, "boom")

      expect { described_class.call(project: project, score: 80) }.not_to raise_error
    end
  end
end
