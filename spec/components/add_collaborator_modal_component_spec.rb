# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProjectComponents::AddCollaboratorModalComponent, type: :component do
  let(:user) { create(:user) }
  let(:project) { create(:project) }

  before do
    collaboration = create(:collaboration, user: user, project: project)
    render_inline(described_class.new(collaboration: collaboration))
  end

  it "renders the modal title" do
    have_title(I18n.t("add_members"))
  end

  it "renders the modal description" do
    have_text(I18n.t("projects.add_collaborator_description"))
  end

  it "renders select field for emails" do
    have_selector("select#collaboration_email")
  end

  it "renders submit button" do
    have_button("Add Collaborators")
  end

  it "renders close button" do
    have_button(class: "close")
  end
end
