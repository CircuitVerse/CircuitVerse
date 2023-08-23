# frozen_string_literal: true

require "rails_helper"

describe "Project", type: :system do
  let(:author) { FactoryBot.create(:user) }
  let(:private_project) { FactoryBot.create(:project, author: author, project_access_type: "Private") }
  let(:public_project) { FactoryBot.create(:project, author: author, project_access_type: "Public") }
  let(:collaborator) { FactoryBot.create(:user) }

  before do
    private_project.collaborators << collaborator
    public_project.collaborators << collaborator
    driven_by(:selenium_chrome_headless)
  end

  describe "if private project" do
    it "author can access" do
      sign_in author
      visit user_project_path(author, private_project)
      expect(page).to have_text(private_project.name)
    end

    it "collaborator can access" do
      sign_in collaborator
      visit user_project_path(private_project.author, private_project)
      expect(page).to have_text(private_project.name)
    end

    it "random user can't access" do
      sign_in_random_user
      visit user_project_path(author, private_project)
      expect(page).to have_text("Not Authorized")
    end
  end

  describe "if public project" do
    it "author can access" do
      sign_in author
      visit user_project_path(author, public_project)
      expect(page).to have_text(public_project.name)
    end

    it "collaborator can access" do
      sign_in collaborator
      visit user_project_path(public_project.author, public_project)
      expect(page).to have_text(public_project.name)
    end

    it "random user can access" do
      sign_in_random_user
      visit user_project_path(author, public_project)
      expect(page).to have_text(public_project.name)
    end
  end

  describe "fork project" do
    it "author can't fork own project" do
      sign_in author
      visit user_project_path(private_project.author, private_project)
      expect(page).not_to have_text("Fork")
    end

    it "random user can fork public project" do
      sign_in_random_user
      visit user_project_path(public_project.author, public_project)
      click_on "Fork"
      expect(page).to have_text("Forked")
    end
  end

  describe "author can" do
    before do
      sign_in author
    end

    it "edit name" do
      visit user_project_path(private_project.author, private_project)
      click_on "Edit"
      name = Faker::Name.name
      fill_in "Name", with: name
      click_on "Update Project"

      expect(page).to have_text(name)
    end

    it "can't edit name if provided name is blank" do
      visit user_project_path(private_project.author, private_project)
      click_on "Edit"
      fill_in "Name", with: ""
      click_on "Update Project"

      expect(page).to have_text("Name is too short")
    end

    it "edit description" do
      visit user_project_path(private_project.author, private_project)
      click_on "Edit"
      description = Faker::Lorem.sentence
      fill_in_input ".trumbowyg-editor", with: description
      click_on "Update Project"

      expect(page).to have_text(description)
    end

    it "edit tags" do
      visit user_project_path(private_project.author, private_project)
      click_on "Edit"
      tags_list = Faker::Lorem.words(number: 3)
      tags_string = tags_list.join(",")
      fill_in "Tag List", with: tags_string
      click_on "Update Project"

      tags_list.each do |tag|
        expect(page).to have_text(tag)
      end
    end

    it "change project access type to public" do
      visit user_project_path(private_project.author, private_project)
      click_on "Edit"
      select "Public", from: "Project access type"
      click_on "Update Project"

      expect(page).to have_text("Public")
    end

    it "change project access type to private" do
      visit user_project_path(public_project.author, public_project)
      click_on "Edit"
      select "Private", from: "Project access type"
      click_on "Update Project"

      expect(page).to have_text("Private")
    end

    it "change project access type to limited access" do
      visit user_project_path(public_project.author, public_project)
      click_on "Edit"
      select "Limited access", from: "Project access type"
      click_on "Update Project"
      expect(page).to have_text("Limited access")
    end

    it "add a collaborator" do
      email = Faker::Internet.email
      visit user_project_path(private_project.author, private_project)
      click_on "+ Add a Collaborator"
      project_input_field_id = "#project_email_input_collaborator"
      fill_in_input project_input_field_id, with: email
      fill_in_input project_input_field_id, with: :enter
      click_on "Add Collaborators"
      expect(page).to have_text("1 user(s) will be invited")
    end
  end

  def fill_in_input(editor, with:)
    find(editor).send_keys with
  end
end
