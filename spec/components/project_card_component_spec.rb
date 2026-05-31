# frozen_string_literal: true

require "rails_helper"

RSpec.describe Project::ProjectCardComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:user) { create(:user) }
  let(:author) { create(:user) }

  let(:project) do
    create(:project,
           name: "Test Circuit Project",
           description: "This is a test circuit project.",
           author: author)
  end

  it "renders the project card with core elements" do
    rendered_component = render_inline(described_class.new(project: project))

    expect(rendered_component.to_html).to include(project.name)
    expect(rendered_component.to_html).to include(project.author.name)
    expect(rendered_component.to_html).to include(project.description)
    expect(rendered_component.css(".project-card-stat").to_html).to include(project.stars_count.to_s)
    expect(rendered_component.css(".project-card-stat").to_html).to include(project.view.to_s)
  end

  it "renders a clickable card" do
    rendered_component = render_inline(described_class.new(project: project))
    expect(rendered_component.css("a.project-card").first["href"]).to eq(user_project_path(project.author, project))
  end
end
