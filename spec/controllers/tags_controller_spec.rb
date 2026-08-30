# frozen_string_literal: true

require "rails_helper"

describe TagsController, type: :request do
  describe "#show" do
    before do
      @tag = FactoryBot.create(:tag, name: "Sequential")
      @author = FactoryBot.create(:user)
      @projects = [FactoryBot.create(:project, :public, author: author, name: "Ripple Counter"),
                   FactoryBot.create(:project, :public, author: author, name: "Johnson Counter")]
      @projects.each { |project| FactoryBot.create(:tagging, project: project, tag: @tag) }
    end

    let(:author) { @author }

    it "lists projects with the given tag" do
      get tag_path(@tag.name)
      @projects.each do |project|
        expect(response.body).to include(project.name)
      end
    end

    it "finds the tag case insensitively" do
      get tag_path("sequential")
      expect(response).to have_http_status(:ok)
      @projects.each do |project|
        expect(response.body).to include(project.name)
      end
    end
  end
end
