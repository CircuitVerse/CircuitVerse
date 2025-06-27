# frozen_string_literal: true

require "rails_helper"

RSpec.describe Project::ProjectCardComponent, type: :component do
  let(:user) { create(:user) }
  let(:author) { create(:user) }
  let(:tag) { create(:tag, name: "electronics") }

  let(:project) do
    create(:project,
           name: "Test Circuit Project",
           description: "This is a test circuit project.",
           author: author,
           tags: [tag])
  end

  it "renders the project card with core elements" do
    rendered_component = render_inline(described_class.new(project: project))

    expect(rendered_component.to_html).to include(project.name)
    expect(rendered_component.to_html).to include(project.description)
    expect(rendered_component.to_html).to include(author.name)
    expect(rendered_component.to_html).to include(tag.name)
  end

  it "handles project without tags" do
    project.tags = []
    rendered_component = render_inline(described_class.new(project: project))

    expect(rendered_component.to_html).to include(project.name)
    expect(rendered_component.css(".badge.search-tag")).to be_empty
  end
end
