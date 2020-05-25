# frozen_string_literal: true

require "rails_helper"

describe Users::LogixController, type: :request do
  before do
    @user = FactoryBot.create(:user)
    sign_in @user
  end
  it "should get user projects" do
    get user_projects_path(id: @user.id)
    expect(response.status).to eq(200)
  end
  it "should get user profile" do
    get profile_path(id: @user.id)
    expect(response.status).to eq(200)
  end
  it "should get user settings" do
    get user_settings_path(id: @user.id)
    expect(response.status).to eq(200)
  end
  it "should get user favourites" do
    get user_favourites_path(id: @user.id)
    expect(response.status).to eq(200)
  end

  describe "#groups" do
    before do
      sign_out @user
    end

    context "user logged in is admin" do
      it "should get user groups" do
        sign_in FactoryBot.create(:user, admin: true)
        get user_groups_path(id: @user.id)
        expect(response.status).to eq(200)
      end
    end

    context "logged in user requests its own group" do
      it "should get user groups" do
        sign_in @user
        get user_groups_path(id: @user.id)
        expect(response.status).to eq(200)
      end
    end

    context "logged in user requests some other user's groups" do
      it "should not get groups" do
        sign_in FactoryBot.create(:user)
        get user_groups_path(id: @user.id)
        expect(response.body).to eq("You are not authorized to do the requested operation")
      end
    end
  end
  it "should get edit profile" do
    get profile_edit_path(id: @user.id)
    expect(response.status).to eq(200)
  end
  it "should update user profile" do
    patch profile_update_path(@user), params: {
      id: @user.id,
      user: { name: "Jd", country: "IN", educational_institute: "MAIT" }
    }
    expect(response).to redirect_to(profile_path(id: @user.id))
    expect(@user.name).to eq("Jd")
    expect(@user.country).to eq("IN")
    expect(@user.educational_institute).to eq("MAIT")
  end

  describe "settings.json schema" do
    schema = JSON.parse File.read "public/js/settings.json"

    describe "overall" do
      it "should have atleast one category" do
        expect(schema["categories"].length).to be > 0
      end
      it "should have atleast one setting" do
        expect(schema["settings"].length).to be > 0
      end
    end

    describe "categories" do
      it "should all have name" do
        expect(schema["categories"]).to all include "name"
      end
      it "should all have description" do
        expect(schema["categories"]).to all include "description"
      end
    end

    describe "settings" do
      it "should all have existing category" do
        schema["settings"].each do |s|
          expect(s).to include "category"
          expect(schema["categories"].select{|k, v| k["name"] == s["category"] }.length).to eq(1),
            "'#{s["name"]}' reffers to '#{s["category"]}' category which don't exist"
        end
      end
      it "should all have name" do
        expect(schema["settings"]).to all include "name"
      end
      it "should all have description" do
        expect(schema["settings"]).to all include "description"
      end
      it "should all have action" do
        expect(schema["settings"]).to all include "action"
      end

      describe "actions" do
        it "should all have valid type " do
          valid_actions = ["boolean", "button"]
          schema["settings"].each do |s|
            expect(valid_actions).to include s["action"]["type"]
          end
        end

        it "booleans should keep schema " do
          schema["settings"].select{ |k, v| k["action"]["type"] == "boolean" }.each do |s|
            expect(s["action"]).to include "name"
          end
        end
        it "buttons should keep schema " do
          schema["settings"].select{ |k, v| k["action"]["type"] == "button" }.each do |s|
            expect(s["action"]).to include "buttonText"
            expect(s["action"]).to include "buttonLink"
          end
        end
      end
    end
  end
end
