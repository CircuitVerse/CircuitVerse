# frozen_string_literal: true

require "rails_helper"

describe UserPolicy do
  subject { UserPolicy.new(user, requested_user) }

  before do
    @user = FactoryBot.create(:user)
  end

  describe "#groups" do
    let(:user) { @user }

    context "user is same as requested_user" do
      let(:requested_user) { @user }
      it { should permit(:groups) }
    end

    context "user is admin" do
      let(:requested_user) { @user }
      let(:user) { FactoryBot.create(:user, admin: true) }

      it { should permit(:groups) }
    end

    context "user is not same as requested user" do
      let(:requested_user) { FactoryBot.create(:user) }
      it { should_not permit(:groups) }
    end
  end
end
