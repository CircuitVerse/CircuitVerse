module IntegrationHelper
  # If you do something that triggers a confirm, do it inside an accept_js_confirm or reject_js_confirm block
  def accept_js_confirm
    page.evaluate_script 'window.original_confirm_function = window.confirm;'
    page.evaluate_script 'window.confirm = function(msg) { return true; }'
    yield
    page.evaluate_script 'window.confirm = window.original_confirm_function;'
  end

  # If you do something that triggers a confirm, do it inside an accept_js_confirm or reject_js_confirm block
  def reject_js_confirm
    page.evaluate_script 'window.original_confirm_function = window.confirm;'
    page.evaluate_script 'window.confirm = function(msg) { return false; }'
    yield
    page.evaluate_script 'window.confirm = window.original_confirm_function;'
  end

  # Test that page doesn't redirect (there is probably a much better, built-in way to
  # test this, I just don't know it.
  def page_should_not_redirect
    path = current_path
    text = "bleep bloop"
    page.execute_script "var txt = document.createTextNode('#{text}');document.body.appendChild(txt);"
    yield
    expect(current_path).to eq path
    expect(page).to have_content(text)
  end
end
