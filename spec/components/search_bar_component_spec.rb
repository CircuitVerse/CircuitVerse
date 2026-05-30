# frozen_string_literal: true

require "rails_helper"

RSpec.describe Search::SearchBarComponent, type: :component do
  it "renders the the search bar form" do
    render_inline(described_class.new)

    expect(page).to have_css("form#search-box")
    expect(page).to have_css("form[method='get'][action='/search']")
  end

  it "renders the search input field" do
    render_inline(described_class.new)

    expect(page).to have_field("q", type: "text")
  end

  it "renders the submit button" do
    render_inline(described_class.new)

    expect(page).to have_button(type: "submit")
  end

  describe "#all_sorting_options" do
    let(:component) { described_class.new }

    it "returns all sorting options for all resources" do
      expected_users_options = [
        { value: "created_at", label: I18n.t("components.search_bar.sorting.users.join_date") }.freeze,
        { value: "total_circuits", label: I18n.t("components.search_bar.sorting.users.total_circuits") }.freeze
      ].freeze

      expected_projects_options = [
        { value: "created_at", label: I18n.t("components.search_bar.sorting.projects.created_date") }.freeze,
        { value: "views", label: I18n.t("components.search_bar.sorting.projects.views") }.freeze,
        { value: "stars", label: I18n.t("components.search_bar.sorting.projects.stars") }.freeze
      ].freeze

      expected_all_options = {
        "Users" => expected_users_options,
        "Projects" => expected_projects_options
      }.freeze

      expect(component.all_sorting_options).to eq(expected_all_options)
    end
  end

  describe "sorting options by resource type" do
    let(:component) { described_class.new }

    it "returns correct sorting options for users" do
      expected_options = [
        { value: "created_at", label: I18n.t("components.search_bar.sorting.users.join_date") }.freeze,
        { value: "total_circuits", label: I18n.t("components.search_bar.sorting.users.total_circuits") }.freeze
      ].freeze

      expect(component.send(:sorting_options_for_users)).to eq(expected_options)
    end

    it "returns correct sorting options for projects" do
      expected_options = [
        { value: "created_at", label: I18n.t("components.search_bar.sorting.projects.created_date") }.freeze,
        { value: "views", label: I18n.t("components.search_bar.sorting.projects.views") }.freeze,
        { value: "stars", label: I18n.t("components.search_bar.sorting.projects.stars") }.freeze
      ].freeze

      expect(component.send(:sorting_options_for_projects)).to eq(expected_options)
    end
  end
end
