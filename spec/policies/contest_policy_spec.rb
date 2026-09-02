# frozen_string_literal: true

require "rails_helper"

describe ContestPolicy do
  subject { described_class.new(user, contest) }

  let(:contest) { FactoryBot.create(:contest) }

  context "when the user is a site admin" do
    let(:user) { FactoryBot.create(:user, admin: true) }

    it { is_expected.to permit(:admin) }
  end

  context "when the user is a regular user" do
    let(:user) { FactoryBot.create(:user) }

    it { is_expected.not_to permit(:admin) }
  end

  context "when the user is not logged in" do
    let(:user) { nil }

    it "raises Pundit::NotAuthorizedError" do
      expect { described_class.new(user, contest) }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
