# frozen_string_literal: true

require "rails_helper"

RSpec.describe Adapters::SolrAdapter do
  let(:adapter) { described_class.new }

  # SolrAdapter builds pagination inside the Sunspot `search` block, so we
  # capture that block and evaluate it against a recording double. This lets
  # us assert on the `paginate` arguments (i.e. the sanitized page) without
  # booting a real Solr instance.
  def stub_solr_query(relation, results:)
    query = double("solr_query")
    allow(query).to receive_messages(fulltext: nil, paginate: nil)
    search = double("solr_search", results: results)
    allow(relation).to receive(:search) do |*_args, **_kwargs, &block|
      query.instance_eval(&block)
      search
    end
    query
  end

  describe "#search_project" do
    let(:relation) { double }
    let(:solr_results) { double }

    context "with a search query" do
      it "returns the search results" do
        stub_solr_query(relation, results: solr_results)
        query_params = { q: "circuit", page: 1 }

        result = adapter.search_project(relation, query_params)

        expect(result).to eq(solr_results)
      end

      it "coerces a numeric string page to an integer" do
        query = stub_solr_query(relation, results: solr_results)
        query_params = { q: "circuit", page: "2" }

        adapter.search_project(relation, query_params)

        expect(query).to have_received(:paginate).with(page: 2, per_page: 9)
      end

      it "defaults a malformed page to 1" do
        query = stub_solr_query(relation, results: solr_results)
        query_params = { q: "circuit", page: "1' AND 1=1 UNION SELECT NULL-- -" }

        expect { adapter.search_project(relation, query_params) }.not_to raise_error
        expect(query).to have_received(:paginate).with(page: 1, per_page: 9)
      end
    end

    context "without a search query" do
      it "returns public, non-forked projects" do
        allow(Project).to receive(:public_and_not_forked).and_return(:public_projects)

        expect(adapter.search_project(relation, {})).to eq(:public_projects)
      end
    end
  end

  describe "#search_user" do
    let(:relation) { double }
    let(:solr_results) { double }

    context "with a search query" do
      it "returns the search results" do
        stub_solr_query(relation, results: solr_results)
        query_params = { q: "john", page: 1 }

        result = adapter.search_user(relation, query_params)

        expect(result).to eq(solr_results)
      end

      it "coerces a numeric string page to an integer" do
        query = stub_solr_query(relation, results: solr_results)
        query_params = { q: "john", page: "4" }

        adapter.search_user(relation, query_params)

        expect(query).to have_received(:paginate).with(page: 4, per_page: 9)
      end

      it "defaults a malformed page to 1" do
        query = stub_solr_query(relation, results: solr_results)
        query_params = { q: "john", page: %w[1 2] }

        expect { adapter.search_user(relation, query_params) }.not_to raise_error
        expect(query).to have_received(:paginate).with(page: 1, per_page: 9)
      end
    end

    context "without a search query" do
      it "returns all users" do
        allow(User).to receive(:all).and_return(:all_users)

        expect(adapter.search_user(relation, {})).to eq(:all_users)
      end
    end
  end
end
