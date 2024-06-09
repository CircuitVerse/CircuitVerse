# frozen_string_literal: true

require "rails_helper"

RSpec.describe CategoriesController, type: :controller do
  let(:user) { create(:user) }
  let!(:categories) { create_list(:category, 3) }

  before do
    sign_in user # Assuming Devise is used for authentication
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end

    it "returns all categories" do
      get :index
      expect(response.parsed_body.size).to eq(categories.size)
    end
  end

  describe "POST #create" do
    let(:valid_attributes) { { name: "New Category" } }
    let(:invalid_attributes) { { name: "" } }

    context "with valid params" do
      it "creates a new Category" do
        expect do
          post :create, params: { category: valid_attributes }
        end.to change(Category, :count).by(1)
      end

      it "renders a JSON response with the new category" do
        post :create, params: { category: valid_attributes }
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq("application/json; charset=utf-8")
        expect(response.parsed_body["name"]).to eq("New Category")
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new category" do
        post :create, params: { category: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq("application/json; charset=utf-8")
      end
    end
  end
end
