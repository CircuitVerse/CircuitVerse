class PaginateRenderer < WillPaginate::ActionView::LinkRenderer
  def container_attributes
    {class: "pagination justify-content-center"}
  end

  def page_number(page)

    if page == current_page
      tag("li", link(page, page, class: 'page-link', rel: rel_value(page)), class: "page-item active")
    else
      tag("li", link(page, page, class: 'page-link', rel: rel_value(page)), class: "page-item ")
    end
    # link(page, page, class: 'page-link', rel: rel_value(page))
  end

  def gap
    text = @template.will_paginate_translate(:page_gap) { '&hellip;' }
    %(<span class="mr2">#{text}</span>)
  end

  def previous_page
    num = @collection.current_page > 1 && (@collection.current_page - 1)
    previous_or_next_page(num, @options[:previous_label], 'page-link')
  end

  def next_page
    num = @collection.current_page < total_pages && (@collection.current_page + 1)
    previous_or_next_page(num, @options[:next_label], 'page-link')
  end

  def previous_or_next_page(page, text, _classname)
    if page
      tag("li",
          link(text, page, class: "page-link", rel: rel_value(page)),
          class: "page-item")
    else
      tag("li",
          tag(:span, text, class: "page-link"),
          class: "page-item disabled")
    end
  end
end
