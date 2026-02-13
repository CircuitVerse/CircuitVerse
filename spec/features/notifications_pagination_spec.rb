# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Notifications Pagination', type: :feature do
  let(:user) { create(:user) }
  let!(:notifications) { create_list(:notification, 25, recipient: user) }
  let!(:unread_notifications) { create_list(:notification, 15, recipient: user, read_at: nil) }

  background do
    sign_in user
    visit notifications_path(user)
  end

  scenario 'Shows first page of notifications' do
    expect(page).to have_css('.notification', count: 10)
    expect(page).to have_content('Notifications')
  end

  scenario 'Shows pagination controls when there are multiple pages' do
    expect(page).to have_css('.pagination')
    expect(page).to have_css('.page-item')
    expect(page).to have_link('2')
    expect(page).to have_link('Next')
  end

  scenario 'Navigates to next page' do
    click_link '2'
    expect(page).to have_current_path(notifications_path(user, page: 2))
    expect(page).to have_css('.notification', count: 10)
  end

  scenario 'Navigates to previous page' do
    visit notifications_path(user, page: 2)
    click_link 'Previous'
    expect(page).to have_current_path(notifications_path(user, page: 1))
  end

  scenario 'Shows correct page number in URL' do
    click_link '3'
    expect(page).to have_current_path(notifications_path(user, page: 3))
  end

  scenario 'Tab switching maintains pagination state' do
    # Navigate to page 2
    click_link '2'
    expect(page).to have_current_path(notifications_path(user, page: 2))
    
    # Switch to unread tab
    click_link 'Unread'
    expect(page).to have_current_path(notifications_path(user, page: 2, tab: 'unread'))
    
    # Switch back to all tab
    click_link 'All'
    expect(page).to have_current_path(notifications_path(user, page: 2, tab: 'all'))
  end

  scenario 'Pagination works for unread notifications' do
    click_link 'Unread'
    expect(page).to have_css('.notification', count: 10)
    expect(page).to have_css('.pagination')
    
    click_link '2'
    expect(page).to have_current_path(notifications_path(user, page: 2, tab: 'unread'))
    expect(page).to have_css('.notification', count: 5) # Only 5 unread on second page
  end

  scenario 'Shows no pagination when there are fewer than 10 notifications' do
    # Delete all notifications except 5
    NoticedNotification.where(recipient: user).limit(20).destroy_all
    
    visit notifications_path(user)
    expect(page).not_to have_css('.pagination')
    expect(page).to have_css('.notification', count: 5)
  end

  scenario 'Handles invalid page numbers gracefully' do
    visit notifications_path(user, page: 999)
    expect(page).to have_current_path(notifications_path(user, page: 1))
    expect(page).to have_css('.notification', count: 10)
  end

  scenario 'Maintains tab state when paginating' do
    # Start on unread tab
    click_link 'Unread'
    expect(page).to have_css('#unread-notifications.active')
    
    # Paginate while on unread tab
    click_link '2'
    expect(page).to have_css('#unread-notifications.active')
    expect(page).to have_current_path(notifications_path(user, page: 2, tab: 'unread'))
  end

  scenario 'Mark as read works with pagination' do
    click_link 'Unread'
    first_notification = first('.notification')
    
    expect {
      first_notification.click
    }.to change(user.notifications.unread, :count).by(-1)
  end

  scenario 'Mark all as read works with pagination' do
    click_link 'Unread'
    expect(page).to have_css('.notification', count: 10)
    
    click_link 'Mark all as read'
    expect(page).to have_content('No unread notifications')
  end

  scenario 'URL parameters are preserved when switching tabs' do
    # Navigate to page 3
    visit notifications_path(user, page: 3)
    
    # Switch tabs
    click_link 'Unread'
    expect(page).to have_current_path(notifications_path(user, page: 3, tab: 'unread'))
    
    # Switch back
    click_link 'All'
    expect(page).to have_current_path(notifications_path(user, page: 3, tab: 'all'))
  end

  scenario 'Pagination controls have proper styling' do
    expect(page).to have_css('.pagination.justify-content-center')
    expect(page).to have_css('.page-item.active')
    expect(page).to have_css('.page-link')
  end

  scenario 'Shows correct notification count in title' do
    expect(page).to have_title('(15) Notifications')
    
    # Mark all as read
    click_link 'Mark all as read'
    expect(page).to have_title('Notifications')
  end
end
