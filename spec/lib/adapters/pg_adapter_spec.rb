# frozen_string_literal: true

require "rails_helper"

RSpec.describe Adapters::PgAdapter do
  let(:adapter) { described_class.new }
  let(:mock_relation) { instance_double(ActiveRecord::Relation) }

  describe "#apply_project_sorting" do
    it "covers missing coverage for created_at sorting" do
      query_params = { sort_by: "created_at", sort_direction: "desc" }

      expect(mock_relation).to receive(:order).with(created_at: :desc)

      adapter.send(:apply_project_sorting, mock_relation, query_params)
    end

    it "covers missing coverage for views sorting" do
      query_params = { sort_by: "views", sort_direction: "desc" }

      expect(mock_relation).to receive(:order).with(view: :desc)

      adapter.send(:apply_project_sorting, mock_relation, query_params)
    end

    it "covers missing coverage for stars sorting" do
      query_params = { sort_by: "stars", sort_direction: "desc" }

      expect(mock_relation).to receive(:order).with(stars_count: :desc)

      adapter.send(:apply_project_sorting, mock_relation, query_params)
    end
  end

  describe "#apply_user_sorting" do
    it "covers missing coverage for created_at sorting" do
      query_params = { sort_by: "created_at", sort_direction: "desc" }

      expect(mock_relation).to receive(:order).with(created_at: :desc)

      adapter.send(:apply_user_sorting, mock_relation, query_params)
    end

    it "covers missing coverage for projects sorting" do
      query_params = { sort_by: "projects", sort_direction: "desc" }

      expect(mock_relation).to receive(:order).with(projects_count: :desc)

      adapter.send(:apply_user_sorting, mock_relation, query_params)
    end
  end
end
