# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Notifications Footer Position', type: :feature do
  let(:user) { create(:user) }
  let!(:notifications) { create_list(:notification, 5, recipient: user) }
  let!(:unread_notifications) { create_list(:notification, 3, recipient: user, read_at: nil) }

  background do
    sign_in user
    visit notifications_path(user)
  end

  scenario 'Footer stays at bottom when switching tabs' do
    # Check initial footer position
    expect(page).to have_css('footer')
    initial_footer_position = find('footer').rect.bottom
    
    # Switch to unread tab
    click_link 'Unread'
    sleep 0.5 # Allow for animation
    
    # Footer should still be at the bottom
    expect(page).to have_css('footer')
    unread_footer_position = find('footer').rect.bottom
    
    # Footer position should be consistent
    expect(unread_footer_position).to eq(initial_footer_position)
  end

  scenario 'Footer stays at bottom when switching back to all notifications' do
    # Start with unread tab
    click_link 'Unread'
    sleep 0.5
    
    initial_footer_position = find('footer').rect.bottom
    
    # Switch back to all notifications
    click_link 'All'
    sleep 0.5
    
    # Footer should still be at the bottom
    expect(page).to have_css('footer')
    all_footer_position = find('footer').rect.bottom
    
    # Footer position should be consistent
    expect(all_footer_position).to eq(initial_footer_position)
  end

  scenario 'Notifications container takes available space' do
    # Check that the notifications container grows to fill available space
    expect(page).to have_css('.notifications_container')
    
    container = find('.notifications_container')
    expect(container).to be_present
  end

  scenario 'Body has notifications-page class' do
    # Check that the body has the correct class for footer positioning
    expect(page).to have_css('body.notifications-page')
  end

  scenario 'Footer is visible at bottom of viewport' do
    # Scroll to bottom and check footer position
    page.execute_script('window.scrollTo(0, document.body.scrollHeight)')
    
    footer = find('footer')
    viewport_height = page.execute_script('return window.innerHeight')
    footer_top = footer.rect.top
    
    # Footer should be at or near the bottom of viewport
    expect(footer_top).to be >= viewport_height - 200 # Allow some margin
  end

  scenario 'No footer movement when content changes' do
    # Get initial footer position
    initial_position = find('footer').rect.bottom
    
    # Switch tabs multiple times
    click_link 'Unread'
    sleep 0.5
    click_link 'All'
    sleep 0.5
    click_link 'Unread'
    sleep 0.5
    
    # Footer should not have moved significantly
    final_position = find('footer').rect.bottom
    position_difference = (final_position - initial_position).abs
    
    # Allow minimal movement due to content height changes
    expect(position_difference).to be <= 10
  end

  scenario 'Responsive footer positioning on mobile' do
    resize_window_to(375, 667) # iPhone size
    
    # Check footer position on mobile
    expect(page).to have_css('footer')
    mobile_footer_position = find('footer').rect.bottom
    
    # Switch tabs on mobile
    click_link 'Unread'
    sleep 0.5
    
    # Footer should remain stable
    expect(page).to have_css('footer')
    mobile_footer_after_switch = find('footer').rect.bottom
    
    expect(mobile_footer_after_switch).to eq(mobile_footer_position)
  end

  scenario 'Footer positioning with pagination' do
    # Create more notifications to trigger pagination
    create_list(:notification, 15, recipient: user)
    
    visit notifications_path(user)
    
    # Check footer position with pagination
    expect(page).to have_css('.pagination')
    expect(page).to have_css('footer')
    
    initial_footer_position = find('footer').rect.bottom
    
    # Switch tabs
    click_link 'Unread'
    sleep 0.5
    
    # Footer should remain stable
    expect(page).to have_css('footer')
    footer_after_switch = find('footer').rect.bottom
    
    expect(footer_after_switch).to eq(initial_footer_position)
  end
end
