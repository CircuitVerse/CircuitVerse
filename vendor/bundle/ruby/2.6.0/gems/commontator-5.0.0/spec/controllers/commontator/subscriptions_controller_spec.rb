require 'rails_helper'

module Commontator
  RSpec.describe SubscriptionsController, type: :controller do
    routes { Commontator::Engine.routes }

    before(:each) do
      setup_controller_spec
    end

    it "won't subscribe unless authorized" do
      put :subscribe, params: { id: @thread.id }
      expect(response).to have_http_status(:forbidden)
      expect(@thread.subscription_for(nil)).to be_nil
      expect(@thread.subscription_for(@user)).to be_nil

      sign_in @user
      put :subscribe, params: { id: @thread.id }
      expect(response).to have_http_status(:forbidden)
      expect(@thread.subscription_for(@user)).to be_nil

      @thread.subscribe(@user)
      @user.can_read = true
      put :subscribe, params: { id: @thread.id }
      expect(response).to redirect_to(@thread)
      expect(assigns(:thread).errors).not_to be_empty
    end

    it 'must subscribe if authorized' do
      sign_in @user

      @user.can_read = true
      put :subscribe, params: { id: @thread.id }
      expect(response).to redirect_to(@thread)
      expect(assigns(:thread).errors).to be_empty
      expect(@thread.subscription_for(@user)).not_to be_nil

      @thread.unsubscribe(@user)
      @user.can_read = false
      @user.can_edit = true
      put :subscribe, params: { id: @thread.id }
      expect(response).to redirect_to(@thread)
      expect(assigns(:thread).errors).to be_empty
      expect(@thread.subscription_for(@user)).not_to be_nil

      @thread.unsubscribe(@user)
      @user.can_edit = false
      @user.is_admin = true
      put :subscribe, params: { id: @thread.id }
      expect(response).to redirect_to(@thread)
      expect(assigns(:thread).errors).to be_empty
      expect(@thread.subscription_for(@user)).not_to be_nil
    end

    it "won't unsubscribe unless authorized" do
      @thread.subscribe(@user)
      put :unsubscribe, params: { id: @thread.id }
      expect(response).to have_http_status(:forbidden)
      expect(@thread.subscription_for(nil)).to be_nil
      expect(@thread.subscription_for(@user)).not_to be_nil

      sign_in @user
      put :unsubscribe, params: { id: @thread.id }
      expect(response).to have_http_status(:forbidden)
      expect(@thread.subscription_for(@user)).not_to be_nil

      @thread.unsubscribe(@user)
      @user.can_read = true
      put :unsubscribe, params: { id: @thread.id }
      expect(response).to redirect_to(@thread)
      expect(assigns(:thread).errors).not_to be_empty
    end

    it 'must unsubscribe if authorized' do
      sign_in @user

      @thread.subscribe(@user)
      @user.can_read = true
      put :unsubscribe, params: { id: @thread.id }
      expect(response).to redirect_to(@thread)
      expect(assigns(:thread).errors).to be_empty
      expect(@thread.subscription_for(@user)).to be_nil

      @thread.subscribe(@user)
      @user.can_read = false
      @user.can_edit = true
      put :unsubscribe, params: { id: @thread.id }
      expect(response).to redirect_to(@thread)
      expect(assigns(:thread).errors).to be_empty
      expect(@thread.subscription_for(@user)).to be_nil

      @thread.subscribe(@user)
      @user.can_edit = false
      @user.is_admin = true
      put :unsubscribe, params: { id: @thread.id }
      expect(response).to redirect_to(@thread)
      expect(assigns(:thread).errors).to be_empty
      expect(@thread.subscription_for(@user)).to be_nil
    end
  end
end
