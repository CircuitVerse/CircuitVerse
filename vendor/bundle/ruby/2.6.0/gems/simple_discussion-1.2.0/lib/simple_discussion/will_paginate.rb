require 'will_paginate/view_helpers/action_view'

module SimpleDiscussion
  # This code serves two purposes
  # 1. It patches will_paginate to work with scoped and mounted Rails engines
  #    by adding in the url_builder option
  # 2. It adds Bootstrap 4 styling to will_paginate

  class BootstrapLinkRenderer < WillPaginate::ActionView::LinkRenderer

    # This method adds the `url_builder` option so we can pass in the
    # mounted Rails engine's scope for will_paginate
    def url(page)
      @base_url_params ||= begin
                             url_params = merge_get_params(default_url_params)
                             merge_optional_params(url_params)
                           end

      url_params = @base_url_params.dup
      add_current_page_param(url_params, page)

      # Add optional url_builder support
      (@options[:url_builder] || @template).url_for(url_params)
    end

    protected
    def html_container(html)
      tag :nav, tag(:ul, html, class: ul_class)
    end

    def page_number(page)
      item_class = if(page == current_page)
        'active page-item'
      else
        'page-item'
      end

      tag :li, link(page, page, :rel => rel_value(page), :class => 'page-link'), :class => item_class
    end

    def gap
      tag :li, link('&hellip;'.html_safe, '#', :class => 'page-link'), :class => 'page-item disabled'
    end

    def previous_or_next_page(page, text, classname)
      tag :li, link(text, page || '#', :class => 'page-link'), :class => [(classname[0..3] if  @options[:page_links]), (classname if @options[:page_links]), ('disabled' unless page), 'page-item'].join(' ')
    end

    def ul_class
       ["pagination", container_attributes[:class]].compact.join(" ")
    end
  end
end
