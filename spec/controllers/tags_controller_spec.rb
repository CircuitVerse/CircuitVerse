# frozen_string_literal: true

require "rails_helper"

describe TagsController, type: :request do
  describe "#show" do
    before do
      @tag = FactoryBot.create(:tag)
      @author = FactoryBot.create(:user)
      @projects = [FactoryBot.create(:project, author: author),
                   FactoryBot.create(:project, author: author)]
      @projects.each { |project| FactoryBot.create(:tagging, project: project, tag: @tag) }
    end

    let(:author) { @author }

    it "lists projects with the given tag" do
      get tag_path(@tag.name)
      @projects.each do |project|
        expect(response.body).to include(project.name)
      end
    end
  end
end
