class Commontator::LinkRenderer < WillPaginate::ActionView::LinkRenderer
  protected

  def html_container(html)
    html = "<span class=\"name\">#{@options[:name]}</span>#{html}" if @options[:name]
    tag(:div, html, container_attributes)
  end

  def url(page)
    @base_url_params ||= begin
      url_params = merge_get_params(default_url_params)
      merge_optional_params(url_params)
    end

    url_params = @base_url_params.dup
    add_current_page_param(url_params, page)

    @template.commontator.url_for(url_params)
  end

  private

  def link(text, target, attributes = {})
    attributes = attributes.merge('data-remote' => true) if @options[:remote]
    super
  end
end
