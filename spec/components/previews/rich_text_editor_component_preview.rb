# frozen_string_literal: true

class RichTextEditorComponentPreview < ViewComponent::Preview
  def default
    render(FormComponents::RichTextEditorComponent.new(editor_content: "Hello, world!"))
  end
end