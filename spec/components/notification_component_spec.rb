# frozen_string_literal: true

require "rails_helper"

RSpec.describe LayoutComponents::NotificationComponent, type: :component do
  include ViewComponent::TestHelpers

  let(:user) { FactoryBot.create(:user) }

  describe "when user is signed in" do
    it "renders the notification bell" do
      render_inline(described_class.new(current_user: user))

      expect(page).to have_css("i.fas.fa-bell.notification-icon")
    end

    it "renders the notification dropdown modal" do
      render_inline(described_class.new(current_user: user))

      aggregate_failures do
        expect(page).to have_css(".dropdown-menu.dropdown-menu-end.dropdown-notification")
        expect(page).to have_text(I18n.t("users.notifications.heading"))
        expect(page).to have_css("button.cancel-button")
      end
    end
  end

  describe "when user is not signed in" do
    it "does not render anything" do
      render_inline(described_class.new(current_user: nil))

      expect(page).not_to have_css("i.fas.fa-bell")
      expect(page).not_to have_css(".dropdown-menu")
    end
  end
end
