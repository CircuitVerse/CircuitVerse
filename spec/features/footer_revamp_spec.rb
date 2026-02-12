# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Footer Revamp', type: :feature do
  background do
    visit root_path
  end

  scenario 'Footer has proper spacing between sections' do
    # Check that footer is present
    expect(page).to have_css('.footer-container-fluid')
    expect(page).to have_css('.footer-container')
    
    # Check main sections
    expect(page).to have_css('.footer-main-row')
    expect(page).to have_css('.footer-copyright-row')
    
    # Check proper spacing between sections
    main_row = find('.footer-main-row')
    copyright_row = find('.footer-copyright-row')
    
    expect(main_row).to be_present
    expect(copyright_row).to be_present
    
    # Verify margin between main and copyright sections
    main_bottom = main_row.rect.bottom
    copyright_top = copyright_row.rect.top
    space_between = copyright_top - main_bottom
    
    expect(space_between).to be > 30 # pixels of space
  end

  scenario 'Footer links have hover effects' do
    # Check footer links section
    expect(page).to have_css('.footer-links-section')
    expect(page).to have_css('.footer-link-item')
    
    # Check hover effects are applied
    link_items = all('.footer-link-item')
    expect(link_items.length).to be > 0
    
    link_items.each do |link|
      expect(link).to have_css('transition')
      expect(link).to have_css('position')
    end
  end

  scenario 'Social icons have enhanced hover effects' do
    # Check social icons container
    expect(page).to have_css('.footer-social-icons-container')
    expect(page).to have_css('.footer-social-link')
    
    # Check hover effects
    social_links = all('.footer-social-link')
    expect(social_links.length).to be > 0
    
    social_links.each do |link|
      expect(link).to have_css('transition')
      expect(link).to have_css('border-radius')
      expect(link).to have_css('position')
    end
  end

  scenario 'Sponsors section has proper layout' do
    # Check sponsors section
    expect(page).to have_css('.footer-sponsors-section')
    expect(page).to have_css('.footer-sponsors-grid')
    expect(page).to have_css('.footer-sponsor-item')
    
    # Check sponsor items have hover effects
    sponsor_items = all('.footer-sponsor-item')
    expect(sponsor_items.length).to be > 0
    
    sponsor_items.each do |item|
      expect(item).to have_css('transition')
      expect(item).to have_css('border-radius')
    end
  end

  scenario 'Footer is responsive on mobile' do
    # Test mobile responsiveness
    resize_window_to(375, 667) # iPhone size
    
    # Check mobile layout
    expect(page).to have_css('.footer-container')
    
    # Check that elements stack properly on mobile
    social_container = find('.footer-social-icons-container')
    expect(social_container).to be_present
    
    # Check mobile-specific styles
    expect(social_container).to have_css('gap')
  end

  scenario 'Footer has modern gradient background' do
    footer_container = find('.footer-container-fluid')
    
    # Check that gradient background is applied
    expect(footer_container).to have_css('background')
    expect(footer_container).to have_css('border-top')
  end

  scenario 'Footer logo has hover effects' do
    logo_link = find('.footer-logo-link')
    logo = find('.footer-logo')
    
    expect(logo_link).to be_present
    expect(logo).to be_present
    
    # Check hover effects
    expect(logo_link).to have_css('transition')
    expect(logo).to have_css('border-radius')
  end

  scenario 'Copyright section is properly styled' do
    copyright_section = find('.footer-copyright-section')
    copyright_text = find('.footer-copyright-text')
    
    expect(copyright_section).to be_present
    expect(copyright_text).to be_present
    
    # Check styling
    expect(copyright_section).to have_css('border-top')
    expect(copyright_text).to have_css('color')
  end
end
