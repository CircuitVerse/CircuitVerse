# spec/controllers/questions_controller_spec.rb
require 'rails_helper'

RSpec.describe QuestionsController, type: :controller do
  let(:user) { create(:user) }
  let(:moderator) { create(:user, :question_bank_moderator) }
  let(:question) { create(:question) }
  let(:category) { create(:question_category) }

  before do
    Flipper.enable(:question_bank)
  end

  render_views

  describe "GET #index" do
    let!(:questions) { create_list(:question, 3) }

    context "when question bank is enabled" do
      it "returns a successful response" do
        sign_in user
        get :index
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(questions.first.heading)
      end

      it "paginates questions" do
        sign_in user
        get :index, params: { page: 1 }
        expect(response.body).to include(questions.first.heading)
      end

      it "filters questions by category" do
        sign_in user
        question.update(category_id: category.id)
        get :index, params: { category_id: category.id }
        expect(response.body).to include(question.heading)
      end

      it "filters questions by difficulty level" do
        sign_in user
        question.update(difficulty_level: 'easy')
        get :index, params: { difficulty_level: 'easy' }
        expect(response.body).to include(question.heading)
      end

      it "searches questions by query" do
        sign_in user
        question.update(heading: 'Some Query')
        get :index, params: { q: 'Some Query' }
        expect(response.body).to include('Some Query')
      end

      context "when filtering by status" do
        before { sign_in user }

        it "shows attempted questions" do
          create(:question_submission_history, user: user, question: questions.first, status: 'attempted')
          get :index, params: { status: 'attempted' }
          expect(response.body).to include(questions.first.heading)
        end

        it "shows solved questions" do
          create(:question_submission_history, user: user, question: questions.first, status: 'solved')
          get :index, params: { status: 'solved' }
          expect(response.body).to include(questions.first.heading)
        end

        it "shows unattempted questions" do
          get :index, params: { status: 'unattempted' }
          expect(response.body).to include(questions.first.heading)
        end
      end
    end

    context "when question bank is disabled" do
      before { Flipper.disable(:question_bank) }

      it "returns a 403 error" do
        sign_in user
        get :index
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to include("Question bank is currently blocked")
      end
    end
  end

  describe "GET #show" do
    it "renders the question as JSON" do
      sign_in user
      get :show, params: { id: question.id }
      expect(response.content_type).to eq "application/json; charset=utf-8"
      expect(response.body).to include(question.heading)
    end

    it "raises a 404 when question not found" do
      sign_in user
      get :show, params: { id: 999 }
      expect(response).to redirect_to(questions_path)
      expect(flash[:alert]).to eq "Question not found"
    end
  end

  describe "GET #new" do
    context "when question bank is enabled" do
      it "returns a successful response" do
        sign_in moderator
        get :new
        expect(response).to have_http_status(:ok)
      end
    end

    context "when question bank is disabled" do
      before { Flipper.disable(:question_bank) }

      it "redirects to root_path with an alert" do
        sign_in moderator
        get :new
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq "Question bank is currently blocked"
      end
    end
  end

  describe "POST #create" do
    before { sign_in moderator }

    context "with valid attributes" do
      let(:valid_attributes) { attributes_for(:question) }
      
      it "creates a new question" do
        valid_attributes = attributes_for(:question, category_id: create(:question_category).id)
        expect {
          post :create, params: { question: valid_attributes }
        }.to change(Question, :count).by(1)
      end
    end

    context "with invalid attributes" do
      let(:invalid_attributes) { attributes_for(:question, heading: nil) }

      it "does not create a question" do
        expect {
          post :create, params: { question: invalid_attributes }
        }.not_to change(Question, :count)
      end
    end

    context "when user is not a moderator" do
      before { sign_in user }

      it "returns unauthorized" do
        post :create, params: { question: attributes_for(:question) }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PUT #update" do
    before { sign_in moderator }

    context "with valid attributes" do
      let(:valid_attributes) { { heading: "Updated Heading" } }

      it "updates the question" do
        put :update, params: { id: question.id, question: valid_attributes }
        expect(question.reload.heading).to eq "Updated Heading"
      end

      it "redirects to questions_path with notice" do
        put :update, params: { id: question.id, question: valid_attributes }
        expect(response).to redirect_to(questions_path)
        expect(flash[:notice]).to eq "Question was successfully updated."
      end
    end

    context "with invalid attributes" do
      let(:invalid_attributes) { { heading: nil } }

      it "does not update the question" do
        put :update, params: { id: question.id, question: invalid_attributes }
        expect(question.reload.heading).not_to be_nil
      end
    end
  end

  describe "DELETE #destroy" do
    before { sign_in moderator }

    it "deletes the question" do
      question = create(:question)
      expect {
        delete :destroy, params: { id: question.id }
      }.to change(Question, :count).by(-1)
    end

    it "redirects to questions_url with notice" do
      delete :destroy, params: { id: question.id }
      expect(response).to redirect_to(questions_url)
      expect(flash[:notice]).to eq 'Question was successfully deleted.'
    end
  end

  describe "authorization checks" do
    context "when user is not signed in" do
      it "requires authentication for restricted actions" do
        restricted_actions = [:create, :update, :destroy, :edit]
        restricted_actions.each do |action|
          process action, method: :post, params: { id: question.id }
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end
end
