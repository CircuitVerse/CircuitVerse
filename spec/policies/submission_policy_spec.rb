# frozen_string_literal: true

require "rails_helper"

describe SubmissionPolicy do
  subject { described_class.new(user, submission) }

  let(:author)  { FactoryBot.create(:user) }
  let(:project) { FactoryBot.create(:project, author: author) }
  let(:contest) { FactoryBot.create(:contest, status: :live) }
  let(:submission) do
    FactoryBot.create(:submission, contest: contest, project: project, user: author)
  end

  context "when the user is the project owner" do
    let(:user) { author }

    it { is_expected.to permit(:create) }
    it { is_expected.to permit(:destroy) }
  end

  context "when the user is a site admin" do
    let(:user) { FactoryBot.create(:user, admin: true) }

    it { is_expected.not_to permit(:create) }
    it { is_expected.to permit(:destroy) }
  end

  context "when the user is a random user" do
    let(:user) { FactoryBot.create(:user) }

    it { is_expected.not_to permit(:create) }
    it { is_expected.not_to permit(:destroy) }
  end

  context "when the user is not logged in" do
    let(:user) { nil }

    it "raises Pundit::NotAuthorizedError" do
      expect { described_class.new(user, submission) }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
