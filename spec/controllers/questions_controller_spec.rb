# frozen_string_literal: true

require "rails_helper"

RSpec.describe QuestionsController, type: :controller do
  let(:user) { create(:user) }
  let(:moderator) { create(:user, :question_bank_moderator) }
  let(:category) { create(:question_category) }
  let(:question) { create(:question, category: category) }

  before do
    allow(controller).to receive(:current_user).and_return(moderator)
  end

  describe "GET #index" do
    before do
      sign_in user
      question
    end

    context "with no filters" do
      before { get :index }

      it "returns a success response" do
        expect(response).to be_successful
      end

      it "assigns @questions" do
        expect(assigns(:questions)).to include(question)
      end

      it "assigns @categories" do
        expect(assigns(:categories)).to eq(QuestionCategory.all)
      end
    end

    context "with category filter" do
      let(:another_category) { create(:question_category) }
      let!(:another_question) { create(:question, category: another_category) }

      before { get :index, params: { category_id: category.id } }

      it "filters questions by category" do
        expect(assigns(:questions)).to include(question)
        expect(assigns(:questions)).not_to include(another_question)
      end
    end

    context "with question bank disabled" do
      before do
        allow(Flipper).to receive(:enabled?).with(:question_bank).and_return(true)
        get :index
      end

      it "returns 403 forbidden status" do
        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)["errors"]).to eq("Question bank is currently blocked")
      end
    end
  end

  describe "GET #show" do
    before do
      sign_in user
    end

    context "with existing question" do
      before { get :show, params: { id: question.id } }

      it "returns a success response" do
        expect(response).to be_successful
      end

      it "renders the question as JSON" do
        expect(response.content_type).to eq("application/json; charset=utf-8")
      end
    end

    context "with question bank disabled" do
      before do
        allow(Flipper).to receive(:enabled?).with(:question_bank).and_return(true)
        get :show, params: { id: question.id }
      end

      it "returns 403 forbidden status" do
        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)["errors"]).to eq("Question bank is currently blocked")
      end
    end
  end

  describe "GET #edit" do
    before do
      sign_in user
    end

    context "with existing question" do
      before { get :edit, params: { id: question.id } }

      it "returns a success response" do
        expect(response).to be_successful
      end

      it "assigns the requested question" do
        expect(assigns(:question)).to eq(question)
      end
    end

    context "with non-existing question" do
      before { get :edit, params: { id: -1 } }

      it "redirects to questions path with alert" do
        expect(response).to redirect_to(questions_path)
        expect(flash[:alert]).to eq("Question not found")
      end
    end

    context "with question bank disabled" do
      before do
        allow(Flipper).to receive(:enabled?).with(:question_bank).and_return(true)
        get :edit, params: { id: question.id }
      end

      it "returns 403 forbidden status" do
        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)["errors"]).to eq("Question bank is currently blocked")
      end
    end
  end

  describe "PUT #update" do
    context "as a moderator" do
      before { sign_in moderator }

      context "with valid params" do
        before { put :update, params: { id: question.id, question: { heading: "New Heading" } } }

        it "updates the requested question" do
          question.reload
          expect(question.heading).to eq("New Heading")
        end

        it "redirects to the user path with a notice" do
          expect(response).to redirect_to(questions_path)
          expect(flash[:notice]).to eq("Question was successfully updated.")
        end
      end

      context "with question bank disabled" do
        before do
          allow(Flipper).to receive(:enabled?).with(:question_bank).and_return(true)
          put :update, params: { id: question.id, question: { heading: "New Heading" } }
        end

        it "returns 403 forbidden status" do
          expect(response).to have_http_status(:forbidden)
          expect(JSON.parse(response.body)["errors"]).to eq("Question bank is currently blocked")
        end
      end
    end

    context "as a non-moderator" do
      before { sign_in user }

      it "does not allow updating of the question" do
        put :update, params: { id: question.id, question: { heading: "New Heading" } }
        expect(response).to have_http_status(302)
      end
    end
  end

  describe "DELETE #destroy" do
    context "as a moderator" do
      before { sign_in moderator }

      it "destroys the requested question" do
        question
        expect do
          delete :destroy, params: { id: question.id }
        end.to change(Question, :count).by(-1)
      end

      it "redirects to the questions list with a notice" do
        delete :destroy, params: { id: question.id }
        expect(response).to redirect_to(questions_path)
        expect(flash[:notice]).to eq("Question has been deleted")
      end

      context "with question bank disabled" do
        before do
          allow(Flipper).to receive(:enabled?).with(:question_bank).and_return(true)
          delete :destroy, params: { id: question.id }
        end

        it "returns 403 forbidden status" do
          expect(response).to have_http_status(:forbidden)
          expect(JSON.parse(response.body)["errors"]).to eq("Question bank is currently blocked")
        end
      end
    end

    context "as a non-moderator" do
      before { sign_in user }

      it "does not allow destroying of the question" do
        delete :destroy, params: { id: question.id }
        expect(response).to have_http_status(302)
      end
    end
  end
end
