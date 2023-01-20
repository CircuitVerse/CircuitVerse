# frozen_string_literal: true

require "rails_helper"

RSpec.describe ForumThread, type: :model do
  before do
    @user = FactoryBot.create(:user)
  end

  describe "associations" do
    it { is_expected.to belong_to(:forum_category) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:users) }
    it { is_expected.to have_many(:forum_posts) }
    it { is_expected.to have_many(:optin_subscribers) }
    it { is_expected.to have_many(:optout_subscribers) }
  end
end
