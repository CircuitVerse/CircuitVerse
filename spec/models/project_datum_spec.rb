# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProjectDatum, type: :model do
  # The test environment uses a :null_store, which never caches anything, so
  # swap in a real store to exercise the caching behaviour.
  around do |example|
    original = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    example.run
  ensure
    Rails.cache = original
  end

  let!(:project) { FactoryBot.create(:project) }
  let!(:datum) { FactoryBot.create(:project_datum, project: project) }

  it "Has valid spec" do
    expect(FactoryBot.create(:project)).to be_valid
  end

  describe ".cached_data" do
    it "returns the circuit data for the project" do
      expect(described_class.cached_data(project.id)).to eq(datum.data)
    end

    it "serves the second read from the cache instead of the database" do
      described_class.cached_data(project.id)
      allow(described_class).to receive(:find_by).and_call_original

      expect(described_class.cached_data(project.id)).to eq(datum.data)
      expect(described_class).not_to have_received(:find_by)
    end

    it "returns nil when the project has no circuit data" do
      empty_project = FactoryBot.create(:project)

      expect(described_class.cached_data(empty_project.id)).to be_nil
    end

    it "does not cache the absence of circuit data" do
      empty_project = FactoryBot.create(:project)

      described_class.cached_data(empty_project.id)

      # `read` would return nil either way; `exist?` distinguishes "never
      # written" from "written as an explicit nil".
      expect(Rails.cache.exist?(described_class.cache_key(empty_project.id))).to be(false)
    end

    it "re-queries for a project that has no circuit data" do
      empty_project = FactoryBot.create(:project)
      described_class.cached_data(empty_project.id)
      allow(described_class).to receive(:find_by).and_call_original

      expect(described_class.cached_data(empty_project.id)).to be_nil
      # The spy only records calls made after it was installed, so this is the
      # second read: it must reach the database, unlike a cached hit above.
      expect(described_class).to have_received(:find_by).at_least(:once)
    end

    context "when the cache is unavailable" do
      before do
        allow(Rails.cache).to receive(:fetch).and_raise(Redis::CannotConnectError, "boom")
        allow(Rails.logger).to receive(:warn)
      end

      it "falls back to the database rather than failing the request" do
        expect(described_class.cached_data(project.id)).to eq(datum.data)
      end
    end

    context "when the database read itself fails" do
      it "does not swallow the error and retry the query" do
        call_count = 0
        allow(described_class).to receive(:find_by) do
          call_count += 1
          raise ActiveRecord::QueryCanceled, "canceling statement due to statement timeout"
        end

        expect { described_class.cached_data(project.id) }
          .to raise_error(ActiveRecord::QueryCanceled)
        expect(call_count).to eq(1)
      end
    end
  end

  describe "cache invalidation" do
    # Specs run inside a transaction that is rolled back, and this project does
    # not enable run_commit_callbacks, so after_commit never fires here. The
    # hook is exercised directly; the first example covers the wiring.
    it "is registered as an after_commit hook" do
      callbacks = described_class._commit_callbacks.map(&:filter)

      expect(callbacks).to include(:expire_circuit_data_cache)
    end

    it "drops the cached entry when the hook runs" do
      described_class.cached_data(project.id)
      expect(Rails.cache.read(described_class.cache_key(project.id))).to eq(datum.data)

      datum.send(:expire_circuit_data_cache)

      expect(Rails.cache.read(described_class.cache_key(project.id))).to be_nil
    end

    it "does not break the save when the cache cannot be expired" do
      allow(Rails.cache).to receive(:delete).and_raise(Redis::CannotConnectError, "boom")
      allow(Rails.logger).to receive(:warn)

      expect { datum.send(:expire_circuit_data_cache) }.not_to raise_error
    end

    it "keys the cache per project" do
      expect(described_class.cache_key(project.id)).to eq("project_datum/#{project.id}")
    end
  end
end
