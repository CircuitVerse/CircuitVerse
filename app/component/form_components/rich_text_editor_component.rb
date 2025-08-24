# frozen_string_literal: true

module FormComponents
  class RichTextEditorComponent < ViewComponent::Base
    def initialize(editor_content:)
      @editor_content = editor_content
    end
  end
end