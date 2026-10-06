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

    context "when database statement timeout occurs" do
      it "returns gateway timeout status" do
        allow_any_instance_of(ActiveRecordCursorPaginate::Paginator).to receive(:fetch)
          .and_raise(ActiveRecord::QueryCanceled.new("canceling statement due to statement timeout"))

        get tag_path(@tag.name)
        expect(response).to have_http_status(:gateway_timeout)
      end
    end
  end
end
