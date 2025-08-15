# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExploreService do
  subject(:service) { described_class.new(current_user: user, params: params) }

  let(:user) { nil }
  let(:params) { {} }

  it "exposes the public API" do
    expect(service).to respond_to(
      :circuit_of_the_week,
      :featured_examples,
      :editor_picks,
      :recent_projects,
      :popular_tags
    )
  end

  describe "#featured_examples" do
    it "returns six hashes with required keys" do
      list = service.featured_examples
      expect(list).to be_a(Array)
      expect(list.size).to eq(6)
      expect(list.first.keys).to contain_exactly(:name, :id, :img)
    end
  end

  describe "#circuit_of_the_week" do
    let!(:recent_star_winner) do
      FactoryBot.create(:project, project_access_type: "Public", image_preview: "x.png", view: 5,
                                  created_at: 2.days.ago)
    end
    let!(:most_viewed_fallback) do
      FactoryBot.create(:project, project_access_type: "Public", image_preview: "x.png", view: 10,
                                  created_at: 3.days.ago)
    end

    context "when there are recent stars" do
      before do
        FactoryBot.create_list(:star, 3, project: recent_star_winner, created_at: 1.day.ago)
        FactoryBot.create_list(:star, 1, project: most_viewed_fallback, created_at: 1.day.ago)
      end

      it "returns the most starred project in the last week" do
        expect(service.circuit_of_the_week).to eq(recent_star_winner)
      end
    end

    context "when there are no recent stars" do
      before do
        FactoryBot.create_list(:star, 3, project: recent_star_winner, created_at: 2.weeks.ago)
        FactoryBot.create_list(:star, 1, project: most_viewed_fallback, created_at: 2.weeks.ago)
      end

      it "falls back to the most viewed/open project" do
        expect(service.circuit_of_the_week).to eq(most_viewed_fallback)
      end
    end
  end

  describe "#editor_picks" do
    it "returns up to 6 featured projects ordered by featured at" do
      projects = FactoryBot.create_list(:project, 8, project_access_type: "Public", image_preview: "x.png")
      projects.each_with_index do |proj, i|
        FactoryBot.create(:featured_circuit, project: proj, created_at: i.minutes.ago)
      end

      picks = service.editor_picks
      expect(picks.count).to eq(6)
      expect(picks.first).to eq(projects.first)
    end
  end

  describe "#recent_projects" do
    let(:user) { nil }

    before do
      FactoryBot.create_list(:project, 7, project_access_type: "Public", image_preview: "x.png", created_at: 2.days.ago)
      FactoryBot.create_list(:project, 7, project_access_type: "Public", image_preview: "x.png", created_at: 1.day.ago)
    end

    it "respects per_page and page params" do
      service_with_params = described_class.new(current_user: nil, params: { per_page: 5, page: 2 })
      page = service_with_params.recent_projects
      expect(page.length).to eq(5)
      ids = page.map(&:id)
      expect(ids).to eq(ids.sort.reverse)
    end
  end

  describe "#popular_tags" do
    it "returns tags ordered by usage with tags_count" do
      p1 = FactoryBot.create(:project, project_access_type: "Public", image_preview: "x.png")
      p2 = FactoryBot.create(:project, project_access_type: "Public", image_preview: "x.png")

      p1.tag_list = "adder, alu"
      p1.save!
      p2.tag_list = "adder"
      p2.save!

      tags = service.popular_tags
      expect(tags.first.respond_to?(:tags_count)).to be(true)
      expect(tags.first.tags_count.to_i).to be >= tags.last.tags_count.to_i
      expect(tags.map(&:name)).to include("adder", "alu")
    end
  end
end
