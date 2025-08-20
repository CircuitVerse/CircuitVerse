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

  describe "#current_sorting_options" do
    context "when resource is Users" do
      let(:component) { described_class.new(resource: "Users") }

      it "returns sorting options for users" do
        expected_options = [
          { value: "created_at", label: I18n.t("components.search_bar.sorting.users.join_date") }.freeze,
          { value: "total_circuits", label: I18n.t("components.search_bar.sorting.users.total_circuits") }.freeze
        ].freeze

        expect(component.send(:current_sorting_options)).to eq(expected_options)
      end
    end

    context "when resource is Projects" do
      let(:component) { described_class.new(resource: "Projects") }

      it "returns sorting options for projects" do
        expected_options = [
          { value: "created_at", label: I18n.t("components.search_bar.sorting.projects.created_date") }.freeze,
          { value: "views", label: I18n.t("components.search_bar.sorting.projects.views") }.freeze,
          { value: "stars", label: I18n.t("components.search_bar.sorting.projects.stars") }.freeze
        ].freeze

        expect(component.send(:current_sorting_options)).to eq(expected_options)
      end
    end
  end
end
