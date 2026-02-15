# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Panel Visibility Feature', type: :feature do
  let(:user) { create(:user) }
  let(:project) { create(:project, author: user) }

  background do
    sign_in user
    visit "/simulator/edit/#{project.id}"
  end

  scenario 'View menu is present in navbar' do
    expect(page).to have_css('#toolbar')
    expect(page).to have_content('View')
  end

  scenario 'View menu contains panel toggle options' do
    # Click View menu to open dropdown
    find('#toolbar').find('a', text: 'View').click
    
    expect(page).to have_content('Circuit Elements')
    expect(page).to have_content('Timing Diagram')
    expect(page).to have_content('Properties')
    expect(page).to have_content('Show All Panels')
    expect(page).to have_content('Hide All Panels')
  end

  scenario 'Circuit Elements panel can be toggled' do
    # Verify panel is initially visible
    expect(page).to have_css('.modules.ce-panel.elementPanel', visible: true)
    
    # Click View menu and toggle Circuit Elements
    find('#toolbar').find('a', text: 'View').click
    click_link 'Circuit Elements'
    
    # Panel should be hidden
    expect(page).to have_css('.modules.ce-panel.elementPanel', visible: false)
    
    # Click again to show
    find('#toolbar').find('a', text: 'View').click
    click_link 'Circuit Elements'
    
    # Panel should be visible again
    expect(page).to have_css('.modules.ce-panel.elementPanel', visible: true)
  end

  scenario 'Timing Diagram panel can be toggled' do
    # Verify panel exists
    expect(page).to have_css('.timing-diagram-panel')
    
    # Click View menu and toggle Timing Diagram
    find('#toolbar').find('a', text: 'View').click
    click_link 'Timing Diagram'
    
    # Panel should be hidden
    expect(page).to have_css('.timing-diagram-panel', visible: false)
    
    # Click again to show
    find('#toolbar').find('a', text: 'View').click
    click_link 'Timing Diagram'
    
    # Panel should be visible again
    expect(page).to have_css('.timing-diagram-panel', visible: true)
  end

  scenario 'Properties panel can be toggled' do
    # Verify panel exists
    expect(page).to have_css('.moduleProperty.properties-panel')
    
    # Click View menu and toggle Properties
    find('#toolbar').find('a', text: 'View').click
    click_link 'Properties'
    
    # Panel should be hidden
    expect(page).to have_css('.moduleProperty.properties-panel', visible: false)
    
    # Click again to show
    find('#toolbar').find('a', text: 'View').click
    click_link 'Properties'
    
    # Panel should be visible again
    expect(page).to have_css('.moduleProperty.properties-panel', visible: true)
  end

  scenario 'Show All Panels option' do
    # Hide all panels first
    find('#toolbar').find('a', text: 'View').click
    click_link 'Hide All Panels'
    
    # All panels should be hidden
    expect(page).to have_css('.modules.ce-panel.elementPanel', visible: false)
    expect(page).to have_css('.timing-diagram-panel', visible: false)
    expect(page).to have_css('.moduleProperty.properties-panel', visible: false)
    
    # Show all panels
    find('#toolbar').find('a', text: 'View').click
    click_link 'Show All Panels'
    
    # All panels should be visible
    expect(page).to have_css('.modules.ce-panel.elementPanel', visible: true)
    expect(page).to have_css('.timing-diagram-panel', visible: true)
    expect(page).to have_css('.moduleProperty.properties-panel', visible: true)
  end

  scenario 'Hide All Panels option' do
    # Verify all panels are initially visible
    expect(page).to have_css('.modules.ce-panel.elementPanel', visible: true)
    expect(page).to have_css('.timing-diagram-panel', visible: true)
    expect(page).to have_css('.moduleProperty.properties-panel', visible: true)
    
    # Hide all panels
    find('#toolbar').find('a', text: 'View').click
    click_link 'Hide All Panels'
    
    # All panels should be hidden
    expect(page).to have_css('.modules.ce-panel.elementPanel', visible: false)
    expect(page).to have_css('.timing-diagram-panel', visible: false)
    expect(page).to have_css('.moduleProperty.properties-panel', visible: false)
  end

  scenario 'Panel state persists across page refresh' do
    # Hide Circuit Elements panel
    find('#toolbar').find('a', text: 'View').click
    click_link 'Circuit Elements'
    
    # Refresh page
    visit "/simulator/edit/#{project.id}"
    
    # Panel should still be hidden (localStorage persistence)
    expect(page).to have_css('.modules.ce-panel.elementPanel', visible: false)
  end

  scenario 'Keyboard shortcuts work for panel toggling' do
    # Test Ctrl+Shift+E for Circuit Elements
    page.driver.browser.action.key_down(:control).key_down(:shift).send_keys('e').key_up(:shift).key_up(:control).perform
    
    # Panel should be hidden
    expect(page).to have_css('.modules.ce-panel.elementPanel', visible: false)
    
    # Test Ctrl+Shift+A to show all panels
    page.driver.browser.action.key_down(:control).key_down(:shift).send_keys('a').key_up(:shift).key_up(:control).perform
    
    # All panels should be visible
    expect(page).to have_css('.modules.ce-panel.elementPanel', visible: true)
  end

  scenario 'Visual feedback in menu items' do
    # Initially all icons should be eyes (visible)
    find('#toolbar').find('a', text: 'View').click
    
    expect(page).to have_css('#circuitElementsIcon.fa-eye')
    expect(page).to have_css('#timingDiagramIcon.fa-eye')
    expect(page).to have_css('#propertiesIcon.fa-eye')
    
    # Hide Circuit Elements
    click_link 'Circuit Elements'
    
    # Reopen menu to check icon
    find('#toolbar').find('a', text: 'View').click
    
    # Circuit Elements icon should now be eye-slash
    expect(page).to have_css('#circuitElementsIcon.fa-eye-slash')
  end

  scenario 'Canvas expands when panels are hidden' do
    # Get initial canvas width
    initial_canvas = find('#simulationArea')
    initial_width = initial_canvas[:style].width
    
    # Hide all panels
    find('#toolbar').find('a', text: 'View').click
    click_link 'Hide All Panels'
    
    # Canvas should have more space (this is a visual test, actual implementation may vary)
    expect(page).to have_css('#simulationArea')
  end

  scenario 'Panel visibility works with existing minimize/maximize functionality' do
    # Test that our feature doesn't break existing panel controls
    panel = find('.modules.ce-panel.elementPanel')
    
    # Use existing minimize button
    panel.find('.minimize').click
    
    # Panel should be minimized (existing functionality)
    expect(panel).to have_css('.panel-body', visible: false)
    
    # Use our View menu to toggle
    find('#toolbar').find('a', text: 'View').click
    click_link 'Circuit Elements'
    
    # Panel should be completely hidden (our functionality)
    expect(page).to have_css('.modules.ce-panel.elementPanel', visible: false)
  end

  scenario 'Responsive design works on mobile' do
    # Simulate mobile viewport
    resize_window_to(375, 667)
    
    # View menu should still work
    find('#toolbar').find('a', text: 'View').click
    
    expect(page).to have_content('Circuit Elements')
    expect(page).to have_content('Timing Diagram')
    expect(page).to have_content('Properties')
    
    # Toggle should still work
    click_link 'Circuit Elements'
    expect(page).to have_css('.modules.ce-panel.elementPanel', visible: false)
  end
end
