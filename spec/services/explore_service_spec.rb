# frozen_string_literal: true
require "rails_helper"

RSpec.describe ExploreService do
  let(:user) { FactoryBot.create(:user) }

  describe "#recent_projects" do
    it "returns only public & not forked, paginated" do
      pub = FactoryBot.create(:project, project_access_type: "Public", image_preview: "x.png")
      priv = FactoryBot.create(:project, project_access_type: "Private", image_preview: "x.png")
      svc = described_class.new(current_user: user, params: { page: 1, per_page: 9 })
      recents = svc.recent_projects
      expect(recents).to include(pub)
      expect(recents).not_to include(priv)
    end>
  end

  describe "#circuit_of_the_week" do
    it "picks most starred last 7 days" do
      a1 = FactoryBot.create(:project, project_access_type: "Public", image_preview: "x.png")
      a2 = FactoryBot.create(:project, project_access_type: "Public", image_preview: "x.png")
      3.times { FactoryBot.create(:star, project: a2, user: FactoryBot.create(:user)) }
      1.times { FactoryBot.create(:star, project: a1, user: FactoryBot.create(:user)) }

      svc = described_class.new(current_user: nil, params: {})
      expect(svc.circuit_of_the_week).to eq(a2)
    end
  end

  describe "#editor_picks" do
    it "returns featured circuits" do
      p = FactoryBot.create(:project, project_access_type: "Public", image_preview: "x.png")
      FactoryBot.create(:featured_circuit, project: p)
      svc = described_class.new(current_user: nil, params: {})
      expect(svc.editor_picks).to include(p)
    end
  end

  describe "#popular_tags" do
    it "returns tags ordered by usage" do
      tag1 = FactoryBot.create(:tag, name: "ALU")
      tag2 = FactoryBot.create(:tag, name: "Adder")
      p1 = FactoryBot.create(:project, project_access_type: "Public", image_preview: "x.png")
      p2 = FactoryBot.create(:project, project_access_type: "Public", image_preview: "x.png")
      FactoryBot.create(:tagging, project: p1, tag: tag1)
      FactoryBot.create(:tagging, project: p2, tag: tag1)
      FactoryBot.create(:tagging, project: p2, tag: tag2)

      svc = described_class.new(current_user: nil, params: {})
      names = svc.popular_tags.map(&:name)
      expect(names.first).to eq("ALU")
    end
  end
end
