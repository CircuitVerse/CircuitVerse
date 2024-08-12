# frozen_string_literal: true

require "rails_helper"

RSpec.describe QuestionCategoriesController, type: :controller do
  let(:moderator) { create(:user, :question_bank_moderator) }
  let(:regular_user) { create(:user) }
  let(:valid_attributes) { { name: "Digital Logic" } }
  let(:invalid_attributes) { { name: "" } }

  describe "GET #index" do
    it "returns a success response" do
      QuestionCategory.create!(valid_attributes)
      sign_in moderator
      get :index
      expect(response).to be_successful
      expect(response.parsed_body.first["name"]).to eq("Digital Logic")
    end
  end

  describe "POST #create" do
    context "when the user is a moderator" do
      before { sign_in moderator }

      context "with valid params" do
        it "creates a new Category" do
          expect do
            post :create, params: { category: valid_attributes }
          end.to change(QuestionCategory, :count).by(1)
        end

        it "renders a JSON response with the new category" do
          post :create, params: { category: valid_attributes }
          expect(response).to have_http_status(:created)
          expect(response.parsed_body["name"]).to eq("Digital Logic")
        end
      end
    end

    context "when the user is not a moderator" do
      before { sign_in regular_user }

      it "renders a JSON response with an error" do
        post :create, params: { category: valid_attributes }
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to eq({ "error" => "Unauthorized" })
      end

      it "does not create a new Category" do
        expect do
          post :create, params: { category: valid_attributes }
        end.not_to change(QuestionCategory, :count)
      end
    end
  end
end
