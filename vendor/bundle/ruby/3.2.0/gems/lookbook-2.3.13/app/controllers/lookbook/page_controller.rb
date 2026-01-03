require "rails/application_controller"

module Lookbook
  class PageController < Rails::ApplicationController
    helper UiElementsHelper
    helper PageHelper

    Lookbook.config.page_paths.each do |path|
      prepend_view_path Rails.root.join(path)
    end

    def render_page(page, locals = {})
      @page = page
      @pages = Engine.pages
      @next_page = @pages.next(@page)
      @previous_page = @pages.previous(@page)

      content = ActionViewConfigHandler.call do
        render_to_string inline: @page.content, locals: {
          page: @page,
          next_page: @next_page,
          previous_page: @previous_page,
          pages: @pages
        }
      end

      @page.markdown? ? MarkdownRenderer.call(content) : content
    end
  end
end
