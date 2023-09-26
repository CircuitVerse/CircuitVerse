# frozen_string_literal: true

require "rails_helper"

RSpec.describe ForumPost do
  before do
    @user = FactoryBot.create(:user)
  end

  describe "associations" do
    it { is_expected.to belong_to(:forum_thread) }
    it { is_expected.to belong_to(:user) }
  end
end
