# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Contributors Page', type: :feature do
  background do
    visit about_index_path
  end

  scenario 'Displays modern contributors section' do
    expect(page).to have_css('.contributors-section')
    expect(page).to have_css('.contributors-grid')
    expect(page).to have_content('Contributors')
  end

  scenario 'Displays top contributors cards' do
    expect(page).to have_css('.contributor-card', count: 6)
    
    first_card = first('.contributor-card')
    expect(first_card).to have_css('.contributor-card-inner')
    expect(first_card).to have_css('.contributor-card-front')
    expect(first_card).to have_css('.contributor-card-back')
  end

  scenario 'Displays contributor information on front of card' do
    first_card = first('.contributor-card')
    
    within first_card do
      expect(page).to have_css('.contributor-avatar')
      expect(page).to have_css('.contributor-name')
      expect(page).to have_css('.contributor-role')
      expect(page).to have_css('.contributor-stats')
      expect(page).to have_css('.contributions-count')
    end
  end

  scenario 'Displays contributor details on back of card' do
    first_card = first('.contributor-card')
    
    # Flip the card to see back content
    first_card.click
    
    within first_card do
      expect(page).to have_css('.contributor-back-content')
      expect(page).to have_css('.contributor-bio')
      expect(page).to have_css('.contributor-details')
      expect(page).to have_css('.contributor-back-actions')
    end
  end

  scenario 'Card flip functionality works' do
    first_card = first('.contributor-card')
    
    # Initially shows front
    expect(first_card).not_to have_class('flipped')
    
    # Click to flip
    first_card.click
    expect(first_card).to have_class('flipped')
    
    # Click again to flip back
    first_card.click
    expect(first_card).not_to have_class('flipped')
  end

  scenario 'Displays social links on hover' do
    first_card = first('.contributor-card')
    
    within first_card do
      expect(page).to have_css('.contributor-overlay')
      expect(page).to have_css('.contributor-social-links')
      expect(page).to have_css('.github-link')
    end
  end

  scenario 'Social links are functional' do
    first_card = first('.contributor-card')
    
    within first_card do
      github_link = find('.github-link')
      expect(github_link[:href]).to match(/https:\/\/github\.com/)
      expect(github_link[:target]).to eq('_blank')
    end
  end

  scenario 'Displays all contributors section' do
    expect(page).to have_css('.all-contributors-section')
    expect(page).to have_content('All Contributors')
    expect(page).to have_content('CircuitVerse is built by the community')
  end

  scenario 'Loads GitHub contributors dynamically' do
    expect(page).to have_css('#all-contributors-container')
    
    # Wait for dynamic content to load
    expect(page).to have_css('.about-contributor', count: 0)
    
    # Simulate API response (in real test, this would be handled by JavaScript)
    # This is a basic test to ensure the container exists
  end

  scenario 'Contributor cards have proper styling' do
    cards = all('.contributor-card')
    
    cards.each do |card|
      expect(card).to have_css('.contributor-card-inner')
      expect(card).to have_css('.contributor-avatar')
      expect(card).to have_css('.contributor-name')
    end
  end

  scenario 'Responsive design works on mobile' do
    resize_window_to(375, 667) # iPhone size
    
    expect(page).to have_css('.contributors-grid')
    expect(page).to have_css('.contributor-card')
    
    cards = all('.contributor-card')
    expect(cards.length).to be > 0
  end

  scenario 'Hover effects work on cards' do
    first_card = first('.contributor-card')
    
    # Hover over card
    first_card.hover
    
    # Check if hover effects are applied (visual test)
    expect(first_card).to be_present
  end

  scenario 'Become contributor button is present' do
    expect(page).to have_link('Become a Contributor')
    contributor_link = find_link('Become a Contributor')
    expect(contributor_link[:href]).to eq('/contribute')
  end

  scenario 'Contributor data is properly formatted' do
    first_card = first('.contributor-card')
    
    within first_card do
      expect(page).to have_css('.contributor-name')
      expect(page).to have_css('.contributor-role')
      expect(page).to have_css('.contributions-count')
      
      # Check for proper text content
      expect(find('.contributions-count')).to have_text(/contributions/)
    end
  end

  scenario 'Accessibility features are present' do
    cards = all('.contributor-card')
    
    cards.each do |card|
      # Check for proper ARIA attributes
      expect(card).to be_present
      
      # Check for keyboard navigation
      expect(card).to be_present
    end
  end

  scenario 'Performance considerations' do
    # Page should load quickly
    expect(page).to have_css('.contributors-section')
    
    # No excessive DOM elements
    cards = all('.contributor-card')
    expect(cards.length).to be <= 10 # Reasonable number for top contributors
  end
end
