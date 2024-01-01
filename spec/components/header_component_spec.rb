# frozen_string_literal: true

require "rails_helper"

RSpec.describe LayoutComponents::HeaderComponent, type: :component do
  before do
    render_inline(described_class.new)
  end

  it "renders the circuitverse logo" do
    have_css("img.navbar-logo")
    have_link(href: "/")
  end

  it "renders the search button" do
    have_css("li.navbar-search-icon-onexpand")
  end

  it "renders the simulator button" do
    have_link(I18n.t("layout.link_to_simulator"), href: "/simulator")
  end

  it "renders the getting started dropdown" do
    have_link(I18n.t("layout.link_to_learn_more"), href: "https://learn.circuitverse.org/")
    have_link(I18n.t("layout.link_to_docs"), href: "https://docs.circuitverse.org/")
  end

  it "renders the features link" do
    have_link(I18n.t("layout.link_to_features"), href: "/#home-features-section")
  end

  it "renders the teachers link" do
    have_link(I18n.t("layout.link_to_teachers"), href: "/teachers")
  end

  it "renders the blog link" do
    have_link(I18n.t("layout.link_to_blog"), href: "https://blog.circuitverse.org/")
  end

  it "renders the about link" do
    have_link(I18n.t("layout.link_to_about"), href: "/about")
  end

  it "renders login button" do
    have_link(I18n.t("login"), href: "/users/sign_in")
  end

  context "when the user is loggin in" do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    it "renders notifications dropdown" do
      have_css("div.dropdown")
    end

    it "renders dashboard link" do
      have_link(I18n.t("layout.header.dashboard"), href: user_path(user))
    end

    it "renders groups link" do
      have_link(I18n.t("layout.header.my_groups"), href: user_groups_path(user))
    end

    it "renders sign out button" do
      have_link(I18n.t("sign_out"), href: destroy_user_session_path)
    end
  end
end
