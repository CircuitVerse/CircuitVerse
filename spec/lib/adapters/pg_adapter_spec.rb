# frozen_string_literal: true

require "rails_helper"

RSpec.describe Adapters::PgAdapter do
  let(:adapter) { described_class.new }
  let(:mock_relation) { double("ActiveRecord::Relation") }

  describe "#apply_project_sorting" do
    before do
      allow(mock_relation).to receive(:order).and_return(mock_relation)
    end

    it "covers missing coverage for created_at sorting" do
      query_params = { sort_by: "created_at", sort_direction: "desc" }

      adapter.send(:apply_project_sorting, mock_relation, query_params)

      expect(mock_relation).to have_received(:order).with(created_at: :desc)
    end

    it "covers missing coverage for views sorting" do
      query_params = { sort_by: "views", sort_direction: "desc" }

      adapter.send(:apply_project_sorting, mock_relation, query_params)

      expect(mock_relation).to have_received(:order).with(view: :desc)
    end

    it "covers missing coverage for stars sorting" do
      query_params = { sort_by: "stars", sort_direction: "desc" }

      adapter.send(:apply_project_sorting, mock_relation, query_params)

      expect(mock_relation).to have_received(:order).with(stars_count: :desc)
    end
  end

  describe "#apply_user_sorting" do
    before do
      allow(mock_relation).to receive(:order).and_return(mock_relation)
    end

    it "covers missing coverage for created_at sorting" do
      query_params = { sort_by: "created_at", sort_direction: "desc" }

      adapter.send(:apply_user_sorting, mock_relation, query_params)

      expect(mock_relation).to have_received(:order).with(created_at: :desc)
    end

    it "covers missing coverage for projects sorting" do
      query_params = { sort_by: "projects", sort_direction: "desc" }

      adapter.send(:apply_user_sorting, mock_relation, query_params)

      expect(mock_relation).to have_received(:order).with(projects_count: :desc)
    end
  end
end
