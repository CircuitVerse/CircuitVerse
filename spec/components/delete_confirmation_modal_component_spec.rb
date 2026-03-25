# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeleteComponents::DeleteConfirmationModalComponent, type: :component do
  it "renders the delete confirmation modal with default parameters" do
    render_inline(described_class.new(
      modal_id: "testModal",
      message_key: "test.message",
      button_id: "test-button",
      delete_path: "/test/delete"
    ))

    expect(page).to have_selector("div#testModal.modal.fade")
    expect(page).to have_text(I18n.t("delete"))
    expect(page).to have_link("", href: "/test/delete", class: "btn primary-delete-button")
    expect(page).to have_selector("button.btn-close[data-bs-dismiss='modal']")
  end

  it "renders with correct modal IDs and message keys" do
    render_inline(described_class.new(
      modal_id: "deletegroupModal",
      message_key: "users.circuitverse.delete_group_confirmation",
      button_id: "groups-group-delete-button",
      delete_path: "#"
    ))

    expect(page).to have_selector("div#deletegroupModal.modal.fade")
    expect(page).to have_selector("#groups-group-delete-button")
  end

  it "renders with custom HTTP method" do
    render_inline(described_class.new(
      modal_id: "testModal",
      message_key: "test.message",
      button_id: "test-button",
      delete_path: "/test/delete",
      method: :put
    ))

    expect(page).to have_link("", href: "/test/delete", class: "btn primary-delete-button")
  end

  it "renders with remote option" do
    render_inline(described_class.new(
      modal_id: "testModal",
      message_key: "test.message",
      button_id: "test-button",
      delete_path: "/test/delete",
      remote: true
    ))

    expect(page).to have_selector("a.primary-delete-button[data-remote='true']")
  end

  it "adds data-bs-dismiss to footer when footer_dismiss is true" do
    render_inline(described_class.new(
      modal_id: "testModal",
      message_key: "test.message",
      button_id: "test-button",
      delete_path: "/test/delete",
      footer_dismiss: true
    ))

    expect(page).to have_selector("div.modal-footer[data-bs-dismiss='modal']")
  end

  it "does not add data-bs-dismiss to footer when footer_dismiss is false" do
    render_inline(described_class.new(
      modal_id: "testModal",
      message_key: "test.message",
      button_id: "test-button",
      delete_path: "/test/delete",
      footer_dismiss: false
    ))

    expect(page).to have_selector("div.modal-footer:not([data-bs-dismiss])")
  end
end
