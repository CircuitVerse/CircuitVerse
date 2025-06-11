# frozen_string_literal: true

require "rails_helper"

RSpec.describe LayoutComponents::HeaderComponent, type: :component do
  include ViewComponent::TestHelpers

  let(:user) { FactoryBot.create(:user) }

  context "when no user is provided" do
    it "renders the circuitverse logo" do
      render_inline(described_class.new)

      aggregate_failures do
        expect(page).to have_css("img.navbar-logo[alt='CircuitVerse Logo']")
        expect(page).to have_link(href: "/")
      end
    end

    it "renders the search icon" do
      render_inline(described_class.new)

      expect(page).to have_css("i.fa-search.search-icon")
    end

    it "renders the simulator link" do
      render_inline(described_class.new)

      expect(page).to have_link(I18n.t("layout.link_to_simulator"), href: "/simulator")
    end

    it "renders the getting started dropdown" do
      render_inline(described_class.new)

      aggregate_failures do
        expect(page).to have_css("a#getting-started-dropdown")
        expect(page).to have_link(I18n.t("layout.link_to_learn_more"), href: "https://learn.circuitverse.org/")
        expect(page).to have_link(I18n.t("layout.link_to_docs"), href: "https://docs.circuitverse.org/")
      end
    end

    it "renders the features link" do
      render_inline(described_class.new)

      expect(page).to have_link(I18n.t("layout.link_to_features"), href: "/#home-features-section")
    end

    it "renders the blog link" do
      render_inline(described_class.new)

      expect(page).to have_link(I18n.t("layout.link_to_blog"), href: "https://blog.circuitverse.org/")
    end

    it "renders the about link" do
      render_inline(described_class.new)

      expect(page).to have_link(I18n.t("layout.link_to_about"), href: "/about")
    end

    it "renders login and signup buttons" do
      render_inline(described_class.new)

      aggregate_failures do
        expect(page).to have_link(I18n.t("login"), href: "/users/sign_in")
        expect(page).to have_link(I18n.t("sign_up"), href: "/users/sign_up")
      end
    end

    it "does not render user dropdown" do
      render_inline(described_class.new)

      expect(page).not_to have_css(".navbar-user-dropdown")
    end
  end

  context "when user is provided" do
    it "renders the user dropdown with username" do
      render_inline(described_class.new(current_user: user))

      aggregate_failures do
        expect(page).to have_css(".navbar-user-dropdown")
        expect(page).to have_text(user.name)
      end
    end

    it "does not render login and signup buttons" do
      render_inline(described_class.new(current_user: user))

      aggregate_failures do
        expect(page).not_to have_link(I18n.t("login"))
        expect(page).not_to have_link(I18n.t("sign_up"))
      end
    end
  end
end
