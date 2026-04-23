# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::NoticedNotificationsController, type: :controller do
  let(:user) { create(:user) }
  let!(:notifications) { create_list(:notification, 25, recipient: user) }
  let!(:unread_notifications) { create_list(:notification, 15, recipient: user, read_at: nil) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns paginated notifications' do
      get :index
      expect(assigns(:notifications)).to respond_to(:total_pages)
      expect(assigns(:notifications).per_page).to eq(10)
      expect(assigns(:notifications).current_page).to eq(1)
    end

    it 'assigns paginated unread notifications' do
      get :index
      expect(assigns(:unread)).to respond_to(:total_pages)
      expect(assigns(:unread).per_page).to eq(10)
      expect(assigns(:unread).current_page).to eq(1)
    end

    it 'paginates notifications correctly' do
      get :index, params: { page: 2 }
      expect(assigns(:notifications).current_page).to eq(2)
      expect(assigns(:unread).current_page).to eq(2)
    end

    it 'limits notifications per page to 10' do
      get :index
      expect(assigns(:notifications).count).to eq(10)
      expect(assigns(:unread).count).to be <= 10
    end

    it 'orders notifications newest first' do
      get :index
      expect(assigns(:notifications).first.created_at).to be > assigns(:notifications).last.created_at
      expect(assigns(:unread).first.created_at).to be > assigns(:unread).last.created_at
    end

    it 'only shows notifications for current user' do
      other_user = create(:user)
      other_notification = create(:notification, recipient: other_user)
      
      get :index
      expect(assigns(:notifications)).not_to include(other_notification)
      expect(assigns(:unread)).not_to include(other_notification)
    end
  end

  describe 'pagination behavior' do
    it 'shows pagination when there are multiple pages' do
      get :index
      expect(assigns(:notifications).total_pages).to be > 1
      expect(assigns(:unread).total_pages).to be > 1
    end

    it 'handles page parameter correctly' do
      get :index, params: { page: 3 }
      expect(assigns(:notifications).current_page).to eq(3)
      expect(assigns(:unread).current_page).to eq(3)
    end

    it 'defaults to page 1 when no page parameter is provided' do
      get :index
      expect(assigns(:notifications).current_page).to eq(1)
      expect(assigns(:unread).current_page).to eq(1)
    end

    it 'handles invalid page numbers gracefully' do
      get :index, params: { page: 999 }
      expect(assigns(:notifications).current_page).to eq(1)
      expect(assigns(:unread).current_page).to eq(1)
    end
  end

  describe 'mark_as_read' do
    let(:notification) { notifications.first }

    it 'marks notification as read' do
      expect {
        post :mark_as_read, params: { notification_id: notification.id }
      }.to change(notification, :read_at).from(nil).to(kind_of(Time))
    end

    it 'redirects to appropriate path' do
      post :mark_as_read, params: { notification_id: notification.id }
      expect(response).to be_a_redirect
    end
  end

  describe 'mark_all_as_read' do
    it 'marks all unread notifications as read' do
      expect {
        patch :mark_all_as_read
      }.to change(user.notifications.unread, :count).from(15).to(0)
    end

    it 'redirects to notifications page' do
      patch :mark_all_as_read
      expect(response).to redirect_to(notifications_path(user))
    end
  end
end
