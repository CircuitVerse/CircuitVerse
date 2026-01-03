module Lookbook
  class PagesController < Lookbook::ApplicationController
    helper_method :page_controller

    def self.controller_path
      "lookbook/pages"
    end

    def index
      landing = Engine.pages.find(&:landing?) || Engine.pages.first
      raise_not_found("Page not found") unless landing.present?

      redirect_to lookbook_page_path(landing.path)
    end

    def show
      @page = @pages.find_by_path(params[:path])
      raise_not_found("Page not found") unless @page

      @page_content = page_controller.render_page(@page)
      @title = @page.title
      @next_page = @pages.next(@page)
      @previous_page = @pages.previous(@page)
    rescue ActionView::Template::Error => err
      raise Lookbook::TemplateError.new(
        original: err,
        file_path: @page.file_path,
        source: @page.content
      )
    end

    protected

    def page_controller
      controller_class = Lookbook.config.page_controller.constantize
      controller = controller_class.new
      controller.request = request
      controller
    end
  end
end
