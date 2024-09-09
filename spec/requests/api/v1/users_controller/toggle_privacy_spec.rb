# spec/controllers/api/v1/users_controller_spec.rb

require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }

  before do
    sign_in user
  end

  describe 'PATCH #toggle_privacy' do
  before do
    sign_in user
  end
    context 'when toggling privacy for the current user' do
      it 'updates the privacy setting' do
        initial_privacy_status = user.public
        patch :toggle_privacy
        user.reload
        expect(user.public).to eq(initial_privacy_status)
      end

      it 'toggles the user privacy setting and redirects to the user show page' do
        patch :toggle_privacy, params: { id: user.id }
  
        user.reload
        expect(user.public).to_not eq(!user.public)
  
        expect(response).to redirect_to(user_path(user))
        expect(flash[:notice]).to eq('Privacy setting updated successfully.')
      end

      it 'displays a success notice' do
        patch :toggle_privacy
        expect(flash[:notice]).to eq('Privacy setting updated successfully.')
      end
    end

    context 'when trying to toggle privacy for another user' do
      before do
        sign_in another_user
      end

      it 'does not allow changing another user’s privacy setting' do
        patch :toggle_privacy, params: { id: user.id }
        expect(response).to redirect_to(user_path(another_user))
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end

    context 'when no user is signed in' do
      before do
        sign_out user
      end

      it 'redirects to the sign-in page' do
        patch :toggle_privacy
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to eq('You need to sign in or sign up before continuing.')
      end
    end
  end
end
