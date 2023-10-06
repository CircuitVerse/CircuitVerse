class SearchPaginateRenderer < WillPaginate::ActionView::LinkRenderer

  def container_attributes
    attributes = super.except(*[:link_options])
    attributes[:additional_class] = "pagination-cont"
    return attributes
  end

  protected

  def page_number(page)
    link_options = @options[:link_options] || {}
    if page == current_page
      tag :li, tag(:span, page, class: 'page-link'), class: 'page-item active'
    else
      link_options.merge! class: 'page-link', rel: rel_value(page)
      tag :li, link(page, page, link_options), class: 'page-item'
    end
  end

  def previous_or_next_page(page, text, classname)
    link_options = @options[:link_options] || {}

    if page
      link_wrapper = link(text, page, link_options.merge(class: 'page-link'))
      tag :li, link_wrapper, class: 'page-item'
    else
      span_wrapper = tag(:span, text, class: 'page-link')
      tag :li, span_wrapper, class: 'page-item disabled'
    end
  end

  def gap
    text = @template.will_paginate_translate(:page_gap) { '&hellip;' }
    %(<li class="page-item disabled" style="padding: 0 8px"> #{text} </li>)
  end

  def previous_page
    num = @collection.current_page > 1 && @collection.current_page - 1
    previous_or_next_page num, @options[:previous_label], 'previous'
  end

  def next_page
    num = @collection.current_page < @collection.total_pages && @collection.current_page + 1
    previous_or_next_page num, @options[:next_label], 'next'
  end
end
