# frozen_string_literal: true

require "rails_helper"

describe Api::V0::ProjectsController, type: :request do
  let(:projects_url) { "/api/v0/projects/" }
  before do
    @author = FactoryBot.create(:user)
  end

  describe "#get_projects" do
    before do
      @tag = FactoryBot.create(:tag)
      @projects = [ FactoryBot.create(:project, author: @author, project_access_type: "Public"),
      FactoryBot.create(:project, author: @author, project_access_type: "Public") ]
      @projects.each { |project| FactoryBot.create(:tagging, project: project, tag: @tag) }
    end

    it "gets all project with public" do
      get projects_url
      expect(response).to be_successful
      expect(response.body).to include(@projects.first.name)

      get tag_path(@tag.name)
      @projects.each do |project|
        expect(response.body).to include(project.name)
      end
    end
  end

  describe "#show" do
    context "project is public" do
      before do
        @project = FactoryBot.create(:project, author: @author, project_access_type: "Public")
      end

      it "shows project and increases views" do
        expect {
          get projects_url + @project.id.to_s
          @project.reload
        }.to change { @project.view }.by(1)

        expect(response.body).to include(@project.name)
      end
    end
  end
end
