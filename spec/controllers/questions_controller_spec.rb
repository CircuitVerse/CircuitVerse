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
  context "when question bank is enabled" do
    before do
      allow(Flipper).to receive(:enabled?).with(:question_bank).and_return(true)
      sign_in user
      get :index
    end

    it "returns a forbidden response" do
      expect(response).to have_http_status(:forbidden)
    end
  end

  context "when question bank is disabled" do
    before do
      allow(Flipper).to receive(:enabled?).with(:question_bank).and_return(false)
      sign_in user
      question
      get :index
    end

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
end

  describe "GET #show" do
    before do
      sign_in user
      get :show, params: { id: question.id }
    end

    it "returns a success response" do
      expect(response).to be_successful
    end

    it "renders the question as JSON" do
      expect(response.content_type).to eq("application/json; charset=utf-8")
    end
  end

  describe "GET #new" do
    context "when question bank is enabled" do
      before do
        sign_in user
        allow(Flipper).to receive(:enabled?).with(:question_bank).and_return(false)
        get :new
      end

      it "returns a success response" do
        expect(response).to be_successful
      end

      it "assigns a new question" do
        expect(assigns(:question)).to be_a_new(Question)
      end
    end

    context "when question bank is disabled" do
      before do
        sign_in user
        allow(Flipper).to receive(:enabled?).with(:question_bank).and_return(true)
        get :new
      end

      it "redirects to root path" do
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Question bank is currently blocked")
      end
    end
  end

  describe "POST #create" do
    context "as a moderator" do
      before { sign_in moderator }

      context "with valid params" do
        it "creates a new Question" do
          expect do
            post :create, params: { question: attributes_for(:question, category_id: category.id) }
          end.to change(Question, :count).by(1)

          puts assigns(:question).errors.full_messages if assigns(:question).errors.any?
        end

        it "redirects to the root path with a notice" do
          post :create, params: { question: attributes_for(:question, category_id: category.id) }
          expect(response).to redirect_to(root_path)
          expect(flash[:notice]).to eq("Question has been added")
        end
      end

      context "with invalid params" do
        it "renders the new template" do
          post :create, params: { question: attributes_for(:question, heading: nil) }
          expect(response).to render_template(:new)
        end
      end
    end

    context "as a non-moderator" do
      before { sign_in user }

      it "does not allow creation of a new Question" do
        post :create, params: { question: attributes_for(:question, category_id: category.id) }
        expect(response).to have_http_status(:found)
      end
    end
  end

  describe "GET #edit" do
    before do
      sign_in user
      get :edit, params: { id: question.id }
    end

    it "returns a success response" do
      expect(response).to be_successful
    end

    it "assigns the requested question" do
      expect(assigns(:question)).to eq(question)
    end
  end

  describe "PUT #update" do
    context "as a moderator" do
      before { sign_in moderator }

      context "with valid params" do
        it "updates the requested question" do
          put :update, params: { id: question.id, question: { heading: "New Heading" } }
          question.reload
          expect(question.heading).to eq("New Heading")
        end

        it "redirects to the user path with a notice" do
          put :update, params: { id: question.id, question: { heading: "New Heading" } }
          expect(response).to redirect_to(questions_path)
          expect(flash[:notice]).to eq("Question was successfully updated.")
        end
      end
    end

    context "as a non-moderator" do
      before { sign_in user }

      it "does not allow updating of the question" do
        put :update, params: { id: question.id, question: { heading: "New Heading" } }
        expect(response).to have_http_status(:found)
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
    end

    context "as a non-moderator" do
      before { sign_in user }

      it "does not allow destroying of the question" do
        delete :destroy, params: { id: question.id }
        expect(response).to have_http_status(:found)
      end
    end
  end
end