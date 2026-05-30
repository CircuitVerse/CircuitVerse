# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProjectComponents::DeleteProjectConfirmationModelComponent, type: :component do
  it "renders the delete project modal" do
    render_inline(described_class.new)

    expect(page).to have_text(I18n.t("projects.delete_project_message"))
    expect(page).to have_text(I18n.t("delete"))
  end
end
