# frozen_string_literal: true

require "rails_helper"

RSpec.describe FormComponents::RichTextEditorComponent, type: :component do
  let(:sample_content) { "This is a sample content" }

  it "renders the editor" do
    render_inline(described_class.new(editor_content: sample_content))
    expect(page).to have_css("textarea#trumbowyg")
    expect(page).to have_content(sample_content)
  end
end
