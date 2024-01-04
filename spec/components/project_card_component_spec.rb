# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProjectCard::ProjectCardComponent, type: :component do
  include Pundit::Authorization
  include Devise::Controllers::Helpers

  before do
    @author = FactoryBot.create(:user)
    @project = FactoryBot.create(:project, author: @author, project_access_type: "Public")
    @current_user = FactoryBot.create(:user)

    render_inline(described_class.new(@project, @author))
  end

  it "renders the project card correctly" do
    expect(page).to have_text(@project.name)
    expect(page).to have_text(I18n.t("view"))
    expect(page).to have_text(I18n.t("more"))
    expect(page).to have_text(I18n.t("launch"))
  end

  it "renders the project card for user with no access" do
    allow(policy(@project)).to receive(:user_access?).and_return(false)

    render_inline(described_class.new(@project, @current_user))

    expect(page).to have_text(I18n.t("fork"))
  end
end
