require 'spec_helper'

describe 'comments', type: :feature do
  it 'creates a new comment', js: true do
    visit root_path
    click_link 'New Comment'

    # New Comment link should disappear
    expect(page).to have_no_link('New Comment')
    # Comment form should appear
    expect(page).to have_field('comment_subject')
    expect(page).to have_field('comment_body')
    expect(page).to have_no_field('comment_file')

    # Filling in form and submitting
    comment_subject = 'A new comment!'
    comment_body = 'Woo, this is my comment, dude.'
    fill_in 'comment_subject', with: comment_subject
    fill_in 'comment_body', with: comment_body
    click_button 'Create Comment'

    # Comment should appear in the comments table
    within '#comments' do
      expect(page).to have_content(comment_subject)
      expect(page).to have_content(comment_body)
    end
    # Form should clear
    expect(page).to have_field('comment_subject', with: '')
    expect(page).to have_field('comment_body', with: '')
    # ...and be replaced by link again
    expect(page).to have_link('Cancel')
  end

  it "cancels creating a comment", js: true do
    visit root_path
    click_link 'New Comment'

    expect(page).to have_field('comment_subject')
    expect(page).to have_link('Cancel')
    click_link 'Cancel'

    # Form should disappear
    expect(page).to have_no_field('comment_subject')
    expect(page).to have_link('New Comment')
  end

  it "deletes a comment", js: true do
    Comment.create(subject: 'The Great Yogurt', body: 'The Schwarz is strong with this one.')
    visit root_path

    within '#comments' do
      expect(page).to have_content('The Great Yogurt')
      accept_js_confirm do
        click_link 'Destroy'
      end

      expect(page).to have_no_content('The Great Yogurt')
    end
  end

  it "uploads a file", js: true do
    visit root_path
    click_link 'New Comment with Attachment'

    expect(page).to have_field('comment_subject')
    expect(page).to have_field('comment_body')
    expect(page).to have_field('comment_attachment')
    expect(page).to have_field('comment_other_attachment')

    comment_subject = 'Newby'
    comment_body = 'Woot, a file!'
    fill_in 'comment_subject', with: comment_subject
    fill_in 'comment_body', with: comment_body

    # Attach file
    file_path = File.join(fixture_path, 'qr.jpg')
    other_file_path = File.join(fixture_path, 'hi.txt')
    attach_file 'comment_attachment', file_path
    attach_file 'comment_other_attachment', other_file_path

    page_should_not_redirect do
      click_button 'Create Comment'
    end

    within '#comments' do
      expect(page).to have_selector("td", text: comment_subject)
      expect(page).to have_selector("td", text: comment_body)
      expect(page).to have_selector("a", text: File.basename(file_path))
      expect(page).to have_selector("a", text: File.basename(other_file_path))
    end
  end

  it "Disables submit button while submitting", js: true do
    visit root_path

    click_link 'New Comment'
    # Needed to make test wait for above to finish
    form = find('form')

    button = find_button('Create Comment')
    page.execute_script(%q{$('form').append('<input name="pause" type="hidden" value=1 />');})

    fill_in 'comment_subject', with: 'Hi'
    fill_in 'comment_body', with: 'there'
    click_button 'Create Comment'

    expect(button[:disabled]).to be true
    expect(button.value).to eq "Submitting..."

    sleep 1.5

    expect(button[:disabled]).to be false
    expect(button.value).to eq "Create Comment"
  end

  it "triggers ajax:remotipartSubmit event hook", js: true do
    visit root_path
    page.execute_script("$(document).delegate('form', 'ajax:remotipartSubmit', function() { $('#comments').after('remotipart!'); });")

    click_link 'New Comment with Attachment'

    fill_in 'comment_subject', with: 'Hi'
    fill_in 'comment_body', with: 'there'
    attach_file 'comment_attachment', File.join(fixture_path, 'qr.jpg')
    click_button 'Create Comment'

    expect(page).to have_content('remotipart!')
  end

  it "allows remotipart submission to be cancelable via event hook", js: true do
    visit root_path
    page.execute_script("$(document).delegate('form', 'ajax:remotipartSubmit', function() { $('#comments').after('remotipart!'); return false; });")

    click_link 'New Comment with Attachment'

    file_path = File.join(fixture_path, 'qr.jpg')
    fill_in 'comment_subject', with: 'Hi'
    fill_in 'comment_body', with: 'there'
    attach_file 'comment_attachment', file_path
    click_button 'Create Comment'

    expect(page).to have_content('remotipart!')

    within '#comments' do
      expect(page).to have_no_content('Hi')
      expect(page).to have_no_content('there')
      expect(page).to have_no_content(File.basename(file_path))
    end
  end

  it "allows custom data-type on form", js: true do
    visit root_path
    page.execute_script("$(document).delegate('form', 'ajax:success', function(evt, data, status, xhr) { $('#comments').after(xhr.responseText); });")

    click_link 'New Comment with Attachment'

    # Needed to make test wait for above to finish
    form = find('form')
    page.execute_script("$('form').attr('data-type', 'html');")

    file_path = File.join(fixture_path, 'qr.jpg')
    fill_in 'comment_subject', with: 'Hi'
    fill_in 'comment_body', with: 'there'
    attach_file 'comment_attachment', file_path
    click_button 'Create Comment'

    expect(page).to have_content('HTML response')
  end

  it "allows users to use ajax response data safely", js: true do
    visit root_path
    page.execute_script("$(document).delegate('form', 'ajax:success', function(evt, data, status, xhr) { $('#comments').after(data); });")

    click_link 'New Comment with Attachment'

    # Needed to make test wait for above to finish
    form = find('form')
    page.execute_script("$('form').attr('data-type', 'html');")

    file_path = File.join(fixture_path, 'qr.jpg')
    fill_in 'comment_subject', with: 'Hi'
    fill_in 'comment_body', with: 'there'
    attach_file 'comment_attachment', file_path
    click_button 'Create Comment'

    expect(page).to have_content('HTML response')
  end

  it "escapes html response content properly", js: true do
    visit root_path
    page.execute_script("$(document).delegate('form', 'ajax:success', function(evt, data, status, xhr) { $('#comments').after(xhr.responseText); });")

    click_link 'New Comment with Attachment'

    # Needed to make test wait for above to finish
    form = find('form')
    page.execute_script("$('form').attr('data-type', 'html');")
    page.execute_script("$('form').append('<input type=\"hidden\" name=\"template\" value=\"escape\" />');")

    file_path = File.join(fixture_path, 'qr.jpg')
    fill_in 'comment_subject', with: 'Hi'
    fill_in 'comment_body', with: 'there'
    attach_file 'comment_attachment', file_path
    click_button 'Create Comment'

    expect(find('input[name="quote"]').value).to eq '"'
  end

  it "returns the correct response status", js: true do
    visit root_path

    click_link 'New Comment with Attachment'
    # Needed to make test wait for above to finish
    input = find('#comment_subject')
    page.execute_script("$('#comment_subject').removeAttr('required');")

    file_path = File.join(fixture_path, 'qr.jpg')
    fill_in 'comment_body', with: 'there'
    attach_file 'comment_attachment', file_path
    click_button 'Create Comment'

    #within '#error_explanation' do
    #  expect(page).to have_content "Subject can't be blank"
    #end
    expect(page).to have_content "Error status code: 422"
    expect(page).to have_content "Error status message: Unprocessable Entity"
  end

  it "passes the method as _method parameter (rails convention)", js: true do
    visit root_path

    click_link 'New Comment with Attachment'
    sleep 0.5
    page.execute_script(%q{$('form').append('<input name="_method" type="hidden" value="put" />');})

    file_path = File.join(fixture_path, 'qr.jpg')
    fill_in 'comment_subject', with: 'Hi'
    fill_in 'comment_body', with: 'there'
    attach_file 'comment_attachment', file_path
    click_button 'Create Comment'

    expect(page).to have_content 'PUT request!'
  end

  it "does not submit via remotipart unless file is present", js: true do
    visit root_path
    page.execute_script("$(document).delegate('form', 'ajax:remotipartSubmit', function() { $('#comments').after('remotipart!'); });")

    click_link 'New Comment with Attachment'

    fill_in 'comment_subject', with: 'Hi'
    fill_in 'comment_body', with: 'there'
    click_button 'Create Comment'

    expect(page).to have_no_content('remotipart!')
  end

  it "fires all the ajax callbacks on the form", js: true do
    visit root_path
    click_link 'New Comment with Attachment'

    # Needed to make test wait for above to finish
    form = find('form')

    page.execute_script("$('form').bind('ajax:beforeSend', function() { $('#comments').after('thebefore'); });")
    page.execute_script("$(document).delegate('form', 'ajax:success', function() { $('#comments').after('success'); });")
    page.execute_script("$(document).delegate('form', 'ajax:complete', function() { $('#comments').after('complete'); });")

    file_path = File.join(fixture_path, 'qr.jpg')
    fill_in 'comment_subject', with: 'Hi'
    fill_in 'comment_body', with: 'there'
    attach_file 'comment_attachment', file_path
    click_button 'Create Comment'

    expect(page).to have_content('before')
    expect(page).to have_content('success')
    expect(page).to have_content('complete')
  end

  it "fires the ajax callbacks for json data-type with remotipart", js: true do
    visit root_path
    click_link 'New Comment with Attachment'

    # Needed to make test wait for above to finish
    form = find('form')

    page.execute_script("$('form').data('type', 'json');")

    page.execute_script("$('form').bind('ajax:beforeSend', function() { $('#comments').after('thebefore'); });")
    page.execute_script("$(document).delegate('form', 'ajax:success', function() { $('#comments').after('success'); });")
    page.execute_script("$(document).delegate('form', 'ajax:complete', function() { $('#comments').after('complete'); });")

    file_path = File.join(fixture_path, 'qr.jpg')
    fill_in 'comment_subject', with: 'Hi'
    fill_in 'comment_body', with: 'there'
    attach_file 'comment_attachment', file_path
    click_button 'Create Comment'

    expect(page).to have_content('before')
    expect(page).to have_content('success')
    expect(page).to have_content('complete')
  end

  it "only fires the beforeSend hook once", js: true do
    visit root_path
    click_link 'New Comment with Attachment'

    # Needed to make test wait for above to finish
    form = find('form')

    page.execute_script("$('form').bind('ajax:beforeSend', function() { $('#comments').after('<div class=\"ajax\">ajax!</div>'); });")

    file_path = File.join(fixture_path, 'qr.jpg')
    fill_in 'comment_subject', with: 'Hi'
    fill_in 'comment_body', with: 'there'
    attach_file 'comment_attachment', file_path
    click_button 'Create Comment'

    expect(page).to have_css("div.ajax", :count => 1)
  end

  it "cleans up after itself when uploading files", js: true do
    visit root_path
    page.execute_script("$(document).delegate('form', 'ajax:remotipartSubmit', function(evt, xhr, data) { if ($(this).data('remotipartSubmitted')) { $('#comments').after('remotipart before!'); } });")

    click_link 'New Comment with Attachment'
    page.execute_script("$('form').attr('data-type', 'html');")

    file_path = File.join(fixture_path, 'qr.jpg')
    fill_in 'comment_subject', with: 'Hi'
    fill_in 'comment_body', with: 'there'
    attach_file 'comment_attachment', file_path
    click_button 'Create Comment'

    expect(page).to have_content('remotipart before!')

    page.execute_script("if (!$('form').data('remotipartSubmitted')) { $('#comments').after('no remotipart after!'); } ")
    expect(page).to have_content('no remotipart after!')
  end

  it "submits via remotipart when a file upload is present", js: true do
    visit root_path
    page.execute_script("$(document).delegate('form', 'ajax:remotipartSubmit', function(evt, xhr, data) { $('#comments').after('<div class=\"remotipart\">remotipart!</div>'); });")

    click_link 'New Comment with Attachment'
    page.execute_script("$('form').attr('data-type', 'html');")

    file_path = File.join(fixture_path, 'qr.jpg')
    fill_in 'comment_subject', with: 'Hi'
    fill_in 'comment_body', with: 'there'
    attach_file 'comment_attachment', file_path
    click_button 'Create Comment'

    expect(page).to have_css("div.remotipart")
  end

  it "does not submit via remotipart when a file upload is not present", js: true do
    visit root_path
    page.execute_script("$(document).delegate('form', 'ajax:remotipartSubmit', function(evt, xhr, data) { $('#comments').after('<div class=\"remotipart\">remotipart!</div>'); });")

    click_link 'New Comment with Attachment'
    page.execute_script("$('form').attr('data-type', 'html');")

    fill_in 'comment_subject', with: 'Hi'
    fill_in 'comment_body', with: 'there'
    click_button 'Create Comment'

    expect(page).not_to have_css("div.remotipart")
  end

  it "Disables submit button while submitting with remotipart", js: true do
    visit root_path

    click_link 'New Comment with Attachment'

    button = find_button('Create Comment')
    # clicking 'Create Comment' button causes capybara evaluation freeze until request ends, so perform check by JavaScript
    page.execute_script("$('form').bind('ajax:remotipartComplete', function(data) { window.commitButtonDisabled = $('input[name=\"commit\"]').is(':disabled'); window.commitButtonValue = $('input[name=\"commit\"]').val(); });")

    file_path = File.join(fixture_path, 'qr.jpg')
    fill_in 'comment_subject', with: 'Hi'
    fill_in 'comment_body', with: 'there'
    attach_file 'comment_attachment', file_path
    click_button 'Create Comment'

    expect(page.evaluate_script("window.commitButtonDisabled")).to be true
    expect(page.evaluate_script("window.commitButtonValue")).to eq "Submitting..."

    expect(button[:disabled]).to be false
    expect(button.value).to eq "Create Comment"
  end

  it "submits the clicked button with the form like non-file remote form", js: true do
    visit root_path
    click_link 'New Comment with Attachment'

    form = find('form')
    page.execute_script("$('form').bind('ajax:remotipartSubmit', function(e, xhr, settings) { $('#comments').after('<div class=\"params\">' + $.param(settings.data) + '</div>'); });")

    file_path = File.join(fixture_path, 'qr.jpg')
    fill_in 'comment_subject', with: 'Hi'
    fill_in 'comment_body', with: 'there'
    attach_file 'comment_attachment', file_path
    click_button 'Create Comment'

    expect(page).to have_content('commit=')
  end

  it "doesn't allow XSS via script injection for text responses", js: true do
    visit "/say?message=%3C/textarea%3E%3Csvg/onload=alert(domain)%3E&remotipart_submitted=x"
    expect(page).to have_selector("textarea")
    expect(find("textarea").value).to eq('</textarea><svg/onload=alert(domain)>')
  end
end
