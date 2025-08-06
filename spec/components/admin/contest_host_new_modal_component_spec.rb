# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::ContestHostNewModalComponent, type: :component do
  it "renders modal with hidden default values and submit button" do
    default_deadline = 1.month.from_now

    render_inline(described_class.new(default_deadline: default_deadline))

    expect(page).to have_css("#host-new-contest-modal")
    expect(page).to have_css(
      "h4.modal-title",
      text: I18n.t("contest.host_new_contest_modal.heading")
    )

    expect(page).to have_css(
      "input[name='contest[status]'][value='live']",
      visible: :hidden
    )

    formatted_deadline = default_deadline.strftime("%Y-%m-%dT%H:%M")
    expect(page).to have_css(
      "input[name='contest[deadline]'][value='#{formatted_deadline}']",
      visible: :hidden
    )

    expect(page).to have_button(
      I18n.t("contest.host_new_contest_modal.confirm_button")
    )
  end
end
