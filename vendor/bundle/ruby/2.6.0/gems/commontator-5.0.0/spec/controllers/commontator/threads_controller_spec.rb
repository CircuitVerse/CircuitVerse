require 'rails_helper'

module Commontator
  RSpec.describe ThreadsController, type: :controller do
    routes { Commontator::Engine.routes }

    before(:each) do
      setup_controller_spec
    end

    it "won't show unless authorized" do
      get :show, params: { id: @thread.id }
      expect(response).to have_http_status(:forbidden)

      sign_in @user
      get :show, params: { id: @thread.id }
      expect(response).to have_http_status(:forbidden)
    end

    it 'must show if authorized' do
      commontable_path = Rails.application.routes.url_helpers.dummy_model_path(@commontable)
      sign_in @user

      @user.can_read = true
      get :show, params: { id: @thread.id }
      expect(response).to redirect_to(commontable_path)

      @user.can_read = false
      @user.can_edit = true
      get :show, params: { id: @thread.id }
      expect(response).to redirect_to(commontable_path)

      @user.can_edit = false
      @user.is_admin = true
      get :show, params: { id: @thread.id }
      expect(response).to redirect_to(commontable_path)
    end

    it "won't close unless authorized and open" do
      put :close, params: { id: @thread.id }
      expect(response).to have_http_status(:forbidden)
      @thread.reload
      expect(@thread.is_closed?).to eq false

      sign_in @user
      put :close, params: { id: @thread.id }
      expect(response).to have_http_status(:forbidden)
      @thread.reload
      expect(@thread.is_closed?).to eq false

      @user.can_read = true
      put :close, params: { id: @thread.id }
      expect(response).to have_http_status(:forbidden)
      @thread.reload
      expect(@thread.is_closed?).to eq false

      @user.can_edit = true
      expect(@thread.close).to eq true
      put :close, params: { id: @thread.id }
      expect(response).to redirect_to(@thread)
      expect(assigns(:thread).errors).not_to be_empty
    end

    it 'must close if authorized and open' do
      sign_in @user

      @user.can_edit = true
      put :close, params: { id: @thread.id }
      expect(response).to redirect_to(@thread)
      expect(assigns(:thread).errors).to be_empty
      expect(assigns(:thread).is_closed?).to eq true
      expect(assigns(:thread).closer).to eq @user

      expect(assigns(:thread).reopen).to eq true
      @user.can_edit = false
      @user.is_admin = true
      put :close, params: { id: @thread.id }
      expect(response).to redirect_to(@thread)
      expect(assigns(:thread).errors).to be_empty
      expect(assigns(:thread).is_closed?).to eq true
      expect(assigns(:thread).closer).to eq @user
    end

    it "won't reopen unless authorized and closed" do
      expect(@thread.close).to eq true
      put :reopen, params: { id: @thread.id }
      expect(response).to have_http_status(:forbidden)
      @thread.reload
      expect(@thread.is_closed?).to eq true

      sign_in @user
      put :reopen, params: { id: @thread.id }
      expect(response).to have_http_status(:forbidden)
      @thread.reload
      expect(@thread.is_closed?).to eq true

      @user.can_read = true
      put :reopen, params: { id: @thread.id }
      expect(response).to have_http_status(:forbidden)
      @thread.reload
      expect(@thread.is_closed?).to eq true

      expect(@thread.reopen).to eq true
      @user.can_edit = true
      put :reopen, params: { id: @thread.id }
      expect(response).to redirect_to(@thread)
      expect(assigns(:thread).errors).not_to be_empty
    end

    it 'must reopen if authorized and closed' do
      sign_in @user

      expect(@thread.close).to eq true
      @user.can_edit = true
      put :reopen, params: { id: @thread.id }
      expect(response).to redirect_to(@thread)
      expect(assigns(:thread).errors).to be_empty
      expect(assigns(:thread).is_closed?).to eq false

      expect(assigns(:thread).close).to eq true
      @user.can_edit = false
      @user.is_admin = true
      put :reopen, params: { id: @thread.id }
      expect(response).to redirect_to(@thread)
      expect(assigns(:thread).errors).to be_empty
      expect(assigns(:thread).is_closed?).to eq false
    end

    context '#mentions' do
      let(:search_phrase) { nil }
      let(:call_request)  do
        get :mentions, params: { id: @thread.id, format: :json, q: search_phrase }
      end

      let!(:other_user)   { DummyUser.create }

      context 'mentions disabled' do
        before(:all) { Commontator.mentions_enabled = false }
        after(:all)  { Commontator.mentions_enabled = true }

        it 'returns 403 Forbidden' do
          call_request
          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'mentions enabled' do
        context 'anonymous user' do
          it 'returns 403 Forbidden' do
            call_request
            expect(response).to have_http_status(:forbidden)
          end
        end

        context 'unauthorized user' do
          before { sign_in @user }

          it 'returns 403 Forbidden' do
            call_request
            expect(response).to have_http_status(:forbidden)
          end
        end

        context 'authorized user' do
          before do
            @user.can_read = true
            sign_in @user
          end

          context 'query is blank' do
            it 'returns a JSON error message' do
              call_request
              expect(response).to have_http_status(:unprocessable_entity)
              expect(JSON.parse(response.body)['errors']).to(
                include('Query string is too short (minimum 3 characters)')
              )
            end
          end

          context 'query is too short' do
            let(:search_phrase) { 'Us' }

            it 'returns a JSON error message' do
              call_request
              expect(response).to have_http_status(:unprocessable_entity)
              expect(JSON.parse(response.body)['errors']).to(
                include('Query string is too short (minimum 3 characters)')
              )
            end
          end

          context 'query is 3 characters or more' do
            let(:search_phrase) { 'User' }

            let(:valid_result) { [@user] }
            let(:valid_response) do
              { 'mentions' => valid_result.map do |user|
                { 'id' => user.id, 'name' => user.name, 'type' => 'user' }
              end }
            end

            it 'calls the user_mentions_proc and returns the result' do
              expect(Commontator.user_mentions_proc).to(
                receive(:call).with(@user, @thread, search_phrase).and_return(valid_result)
              )

              call_request
              expect(response).to have_http_status(:success)

              response_body = JSON.parse(response.body)
              expect(response_body['errors']).to be_nil
              expect(response_body).to eq valid_response
            end
          end
        end
      end
    end
  end
end
