# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProjectComponents::EditProjectFormComponent, type: :component do
  let(:project) { create(:project) }
  let(:user) { create(:user) }

  before do
    render_inline(described_class.new(project: project, current_user: user))
  end

  it "renders the project name field" do
    have_field("project_name")
  end

  it "renders the project tag list" do
    have_field("project_tag_list")
  end

  it "renders the project access type option" do
    have_field("project_project_access_type")
  end

  it "renders the description field" do
    have_selector("div#description")
  end

  it "renders the submit button" do
    have_selector("input[type=submit]")
  end

  it "renders featured_checkbox when user is admin" do
    allow_any_instance_of(ProjectPolicy).to receive(:can_feature?).and_return(true)
    have_field("featured_checkbox")
  end
end
