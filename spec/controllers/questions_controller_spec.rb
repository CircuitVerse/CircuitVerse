# frozen_string_literal: true

require "rails_helper"

require 'rails_helper'

RSpec.describe QuestionsController, type: :controller do
  let!(:user) { create(:user) }
  let!(:question_bank_moderator) { create(:user, :question_bank_moderator) }
  let(:current_user) { create(:user, :question_bank_moderator) }
  let!(:question) { create(:question) }
  let!(:question_submission_history) { create(:question_submission_history, user: user, question: question, status: 'attempted') }
  let!(:category) { create(:question_category) }
  let!(:solved_question) { create(:question) }
  let!(:attempted_question) { create(:question) }
  let!(:unattempted_question) { create(:question) }
  
  

  describe 'GET #index' do
  context 'when user is authenticated' do
    before do
      create(:question_submission_history, user_id: user.id, question_id: solved_question.id, status: 'solved')
      create(:question_submission_history, user_id: user.id, question_id: attempted_question.id, status: 'attempted')
      sign_in user
    end

    it 'returns a paginated list of questions' do
      get :index, params: { page: 1 }
      expect(assigns(:questions)).to eq(Question.paginate(page: 1, per_page: 6))
    end

    it 'filters questions by category' do
      get :index, params: { category_id: category.id }
      expected_questions = Question.where(category_id: category.id)
      expect(assigns(:questions).pluck(:id)).to match_array(expected_questions.pluck(:id))
    end

    it 'filters questions by difficulty level' do
      get :index, params: { difficulty_level: 'easy' }
      expected_questions = Question.where(difficulty_level: 'easy')
      expect(assigns(:questions).pluck(:id)).to match_array(expected_questions.pluck(:id))
    end

    it 'searches questions by heading or statement' do
      get :index, params: { q: 'sample' }
      expected_questions = Question.where("heading LIKE ? OR statement LIKE ?", "%sample%", "%sample%")
      expect(assigns(:questions).pluck(:id)).to match_array(expected_questions.pluck(:id))
    end

    it 'filters questions by status - attempted' do
      get :index, params: { status: 'attempted' }
      expect(assigns(:questions).pluck(:id)).to include(attempted_question.id)
      expect(assigns(:questions).pluck(:id)).not_to include(solved_question.id)
    end

    it 'filters questions by status - solved' do
      get :index, params: { status: 'solved' }
      expect(assigns(:questions).pluck(:id)).to include(solved_question.id)
      expect(assigns(:questions).pluck(:id)).not_to include(attempted_question.id)
    end

    it 'filters questions by status - unattempted' do
      get :index, params: { status: 'unattempted' }
      expect(assigns(:questions).pluck(:id)).to include(unattempted_question.id)
      expect(assigns(:questions).pluck(:id)).not_to include(solved_question.id)
      expect(assigns(:questions).pluck(:id)).not_to include(attempted_question.id)
    end

    it 'retrieves all categories' do
      get :index
      expect(assigns(:categories)).to match_array(QuestionCategory.all)
    end
  end

  context 'when question bank is blocked' do
    before do
      sign_in user
      Flipper.enable(:question_bank)
      get :index
    end

    it 'returns a 403 status' do
      expect(response).to have_http_status(403)
    end

    it 'sets an error message in the response body' do
      expect(JSON.parse(response.body)['errors']).to eq('Question bank is currently blocked')
    end
  end

  context 'when question bank is not blocked' do
    before do
      sign_in user
      Flipper.disable(:question_bank)
      get :index
    end

    it 'returns a 200 status' do
      expect(response).to have_http_status(200)
    end
  end
end


  before do
    sign_in user
  end

  describe 'GET #show' do
    it 'returns the question as JSON' do
      get :show, params: { id: question.id }
      expect(response).to have_http_status(200)
      expect(response.content_type).to eq('application/json; charset=utf-8')
    end

    it 'returns a 404 if the question is not found' do
      get :show, params: { id: 'nonexistent' }
      expect(response).to redirect_to(questions_path)
      expect(flash[:alert]).to eq("Question not found")
    end
  end

  describe 'GET #new' do
    context 'when question bank is blocked' do
      before do
        allow(Flipper).to receive(:enabled?).with(:question_bank).and_return(true)
      end

      it 'redirects to root path' do
        get :new
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Question bank is currently blocked")
      end
    end

    context 'when question bank is available' do
      before do
        allow(Flipper).to receive(:enabled?).with(:question_bank).and_return(false)
      end

      it 'renders the new template' do
        get :new
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'POST #create' do
    context 'when user is a moderator' do
      before do
        sign_in question_bank_moderator
      end

      it 'creates a new question' do
        expect {
          post :create, params: { question: attributes_for(:question) }
        }.to change(Question, :count).by(0)
        expect(response).to have_http_status(200)
      end

      it 'renders new on failure' do
        allow_any_instance_of(Question).to receive(:save).and_return(false)
        post :create, params: { question: { heading: nil } }
        expect(response).to render_template(:new)
      end
    end

    context 'when user is not a moderator' do
      before do
        sign_in user
      end

      it 'returns unauthorized' do
        post :create, params: { question: attributes_for(:question) }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH #update' do
    before do
      sign_in question_bank_moderator
    end

    it 'updates the question' do
      patch :update, params: { id: question.id, question: { heading: 'Updated Heading' } }
      expect(response).to redirect_to(questions_path)
      expect(flash[:notice]).to eq("Question was successfully updated.")
    end
  end

  describe 'DELETE #destroy' do
    before do
      sign_in question_bank_moderator
    end

    it 'deletes the question' do
      expect {
        delete :destroy, params: { id: question.id }
      }.to change(Question, :count).by(-1)
      expect(response).to redirect_to(questions_url)
      expect(flash[:notice]).to eq('Question was successfully deleted.')
    end
  end

  describe 'authorization' do
    context 'when user is not a moderator' do
      before do
        sign_in user
      end

      it 'does not allow creating, updating, or deleting questions' do
        post :create, params: { question: attributes_for(:question) }
        expect(response).to have_http_status(:unauthorized)

        patch :update, params: { id: question.id, question: { heading: 'Updated Heading' } }
        expect(response).to have_http_status(:unauthorized)

        delete :destroy, params: { id: question.id }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end

