# frozen_string_literal: true

require "rails_helper"

RSpec.describe QuestionCategoriesController, type: :controller do
  let(:moderator) { create(:user, :question_bank_moderator) }
  let(:regular_user) { create(:user) }
  let(:valid_attributes) { { name: "Digital Logic" } }
  let(:invalid_attributes) { { name: "" } }

  describe "POST #create" do
    context "when the user is a moderator" do
      before { sign_in moderator }

      it "creates a new category with valid params" do
        expect do
          post :create, params: { name: valid_attributes }
        end.to change(QuestionCategory, :count).by(1)
      end

      it "creates a new category with invalid params" do
        expect do
          post :create, params: { name: "" }
          expect(flash[:alert]).to match(/Missing category information.*/)
        end.not_to change(QuestionCategory, :count)
      end
    end

    context "when the user is not a moderator" do
      before { sign_in regular_user }

      it "does not create a new Category" do
        expect do
          post :create, params: { category: valid_attributes }
          expect(response.body).to eq("You are not authorized to do the requested operation")
        end.not_to change(QuestionCategory, :count)
      end
    end
  end

  describe "DELETE #destroy" do
    context "when the user is a moderator" do
      before do
        sign_in moderator
        @question_category = FactoryBot.create(:question_category)
      end

      it "deletes a existing category" do
        expect do
          delete :destroy, params: { id: @question_category.id }
          expect(flash[:notice]).to match(/Category was successfully removed.*/)
        end.to change(QuestionCategory, :count).by(-1)
      end

      it "deletes a non-existing category" do
        expect do
          delete :destroy, params: { id: 98 }
        end.not_to change(QuestionCategory, :count)
      end
    end

    context "when the user is not a moderator" do
      before do
        sign_in regular_user
        @question_category = FactoryBot.create(:question_category)
      end

      it "does not delete a category" do
        expect do
          delete :destroy, params: { id: @question_category.id }
          expect(response.body).to eq("You are not authorized to do the requested operation")
        end.not_to change(QuestionCategory, :count)
      end
    end
  end
end
