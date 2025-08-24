# frozen_string_literal: true

require "rails_helper"

RSpec.describe Adapters::PgAdapter do
  let(:adapter) { described_class.new }

  describe "#search_project" do
    let(:project_relation) { double }
    let(:paginated_results) { double }
    let(:mock_results) do
      double.tap do |results|
        allow(results).to receive_messages(includes: results, paginate: paginated_results, text_search: results,
                                           order: results)
      end
    end

    before do
      allow(Project).to receive(:public_and_not_forked).and_return(mock_results)
      allow(project_relation).to receive(:text_search).and_return(mock_results)
    end

    context "with search query" do
      let(:query_params) { { q: "test", page: 1 } }

      it "performs text search and returns paginated results" do
        allow(project_relation).to receive(:text_search).with("test").and_return(mock_results)
        allow(mock_results).to receive(:includes).with(:tags, :author).and_return(mock_results)
        allow(mock_results).to receive(:paginate).with(page: 1, per_page: 9).and_return(paginated_results)

        result = adapter.search_project(project_relation, query_params)

        expect(result).to eq(paginated_results)
      end
    end

    context "without search query" do
      let(:query_params) { { page: 1 } }

      it "returns public projects and applies pagination" do
        allow(Project).to receive(:public_and_not_forked).and_return(mock_results)
        allow(mock_results).to receive(:includes).with(:tags, :author).and_return(mock_results)
        allow(mock_results).to receive(:paginate).with(page: 1, per_page: 9).and_return(paginated_results)

        result = adapter.search_project(project_relation, query_params)

        expect(result).to eq(paginated_results)
      end
    end

    context "with sorting parameters" do
      let(:query_params) { { sort_by: "created_at", sort_direction: "desc", page: 1 } }

      it "applies sorting to results" do
        allow(Project).to receive(:public_and_not_forked).and_return(mock_results)

        expect(mock_results).to receive(:order).with(created_at: :desc)

        adapter.search_project(project_relation, query_params)
      end
    end

    context "with tag filters" do
      let(:query_params) { { tag: "electronics,circuit", page: 1 } }
      let(:tag_filtered_results) do
        instance_double(ActiveRecord::Relation).tap do |results|
          allow(results).to receive_messages(includes: results, paginate: paginated_results)
        end
      end

      before do
        allow(mock_results).to receive(:joins).with(:tags).and_return(mock_results)
        allow(mock_results).to receive_messages(where: mock_results, distinct: tag_filtered_results)
      end

      it "filters by tags" do
        expect(mock_results).to receive(:joins).with(:tags)
        expect(mock_results).to receive(:where).with(tags: { name: %w[electronics circuit] })
        expect(mock_results).to receive(:distinct)

        adapter.search_project(project_relation, query_params)
      end
    end
  end

  describe "#search_user" do
    let(:user_relation) { double }
    let(:paginated_results) { double }
    let(:mock_results) do
      double.tap do |results|
        allow(results).to receive_messages(paginate: paginated_results, text_search: results, where: results)
      end
    end

    before do
      allow(User).to receive(:all).and_return(mock_results)
      allow(user_relation).to receive(:text_search).and_return(mock_results)
    end

    context "with search query" do
      let(:query_params) { { q: "john", page: 1 } }

      it "performs text search and returns paginated results" do
        allow(user_relation).to receive(:text_search).with("john").and_return(mock_results)
        allow(mock_results).to receive(:paginate).with(page: 1, per_page: 9).and_return(paginated_results)

        result = adapter.search_user(user_relation, query_params)

        expect(result).to eq(paginated_results)
      end
    end

    context "with country filter" do
      let(:query_params) { { country: "India", page: 1 } }

      it "filters by country case-insensitively" do
        expect(mock_results).to receive(:where).with("LOWER(country) = LOWER(?)", "India")

        adapter.search_user(user_relation, query_params)
      end
    end

    context "with institute filter" do
      let(:query_params) { { institute: "MIT", page: 1 } }

      it "filters by institute using partial matching" do
        expect(mock_results).to receive(:where).with("educational_institute ILIKE ?", "%MIT%")

        adapter.search_user(user_relation, query_params)
      end
    end
  end

  describe "sorting validation" do
    let(:mock_relation) { double }

    before do
      allow(mock_relation).to receive_messages(includes: mock_relation, order: mock_relation)
    end

    it "handles invalid sort fields gracefully" do
      query_params = { sort_by: "invalid_field", page: 1 }

      allow(Project).to receive(:public_and_not_forked).and_return(mock_relation)
      allow(mock_relation).to receive(:paginate).and_return(double)

      # Should not call order for invalid sort field
      expect(mock_relation).not_to receive(:order)

      adapter.search_project(mock_relation, query_params)
    end

    it "handles ascending sort direction" do
      query_params = { sort_by: "created_at", sort_direction: "asc", page: 1 }

      allow(Project).to receive(:public_and_not_forked).and_return(mock_relation)
      allow(mock_relation).to receive(:paginate).and_return(double)

      expect(mock_relation).to receive(:order).with(created_at: :asc)

      adapter.search_project(mock_relation, query_params)
    end
  end
end
