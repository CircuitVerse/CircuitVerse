module Lookbook
  class Header::Component < Lookbook::BaseComponent
    attr_reader :project_logo, :project_name

    def initialize(debug_menu: false, project_name: nil, project_logo: nil, **html_attrs)
      @debug_menu = debug_menu
      @project_logo = project_logo
      @project_name = project_name
      super(**html_attrs)
    end

    def landing_path
      helpers.lookbook_landing_path if defined? helpers.lookbook_landing_path
    end

    def debug_data
      JSON.pretty_generate(Lookbook.debug_data)
    end
  end
end
