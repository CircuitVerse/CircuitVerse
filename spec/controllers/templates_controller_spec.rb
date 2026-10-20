# frozen_string_literal: true

require "rails_helper"

describe TemplatesController, type: :request do
  describe "#index" do
    before do
      @author = FactoryBot.create(:user)
      @adder = create_template("Ripple Adder")
      @counter = create_template("Johnson Counter")
      @tag = FactoryBot.create(:tag, name: "Sequential")
      FactoryBot.create(:tagging, project: @counter, tag: @tag)
    end

    def create_template(name, **attrs)
      FactoryBot.create(:project, :public, author: @author, name: name, is_template: true,
                                           template_visibility: :public, **attrs)
    end

    it "lists public templates" do
      get templates_path
      expect(response.body).to include("Ripple Adder", "Johnson Counter")
    end

    it "excludes non-public templates and ordinary projects" do
      create_template("Group Only", template_visibility: :group)
      create_template("Private One", template_visibility: :private)
      FactoryBot.create(:project, :public, author: @author, name: "Plain Project")
      get templates_path
      expect(response.body).not_to include("Group Only", "Private One", "Plain Project")
    end

    it "searches by name" do
      get templates_path, params: { q: "adder" }
      expect(response.body).to include("Ripple Adder")
      expect(response.body).not_to include("Johnson Counter")
    end

    it "filters by tag" do
      get templates_path, params: { tag: "sequential" }
      expect(response.body).to include("Johnson Counter")
      expect(response.body).not_to include("Ripple Adder")
    end

    it "returns nothing for an unknown tag" do
      get templates_path, params: { tag: "missing" }
      expect(response.body).not_to include("Ripple Adder", "Johnson Counter")
    end

    it "paginates the results" do
      Project.per_page.times { |i| create_template("Extra #{i}") }
      get templates_path
      expect(response.body).to include("pagination")
      get templates_path, params: { page: 2 }
      expect(response).to have_http_status(:ok)
    end
  end
end
