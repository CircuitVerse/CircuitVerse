module Commontator::SharedHelper
  def commontator_set_user
    @commontator_user = Commontator.current_user_proc.call(self)
  end

  def commontator_set_thread(commontable)
    @commontator_thread = commontable.commontator_thread
  end

  def commontator_thread(commontable)
    commontator_set_user
    commontator_set_thread(commontable)

    render(
      partial: 'commontator/shared/thread', locals: {
        user: @commontator_user,
        thread: @commontator_thread,
        page: @commontator_page,
        show_all: @commontator_show_all
      }
    ).html_safe
  end

  def commontator_gravatar_image_tag(user, border = 1, options = {})
    email = Commontator.commontator_email(user) || ''
    name = Commontator.commontator_name(user) || ''

    url = "https://secure.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?#{options.to_query}"

    image_tag(url, alt: name, title: name, border: border)
  end

  # Unlike the Rails versions of split_paragraphs and simple_format, Commontator's:
  # - Split paragraphs on any number of newlines optionally adjacent to spaces
  # - Create all <p> tags (no <br/> tags)
  # - Do not add <p> tags between other html tags
  def commontator_split_paragraphs(text)
    return [] if text.blank?

    text.to_str.gsub(/\r\n?/, "\n").gsub(/>\s*</, ">\n<").split(/\s*\n\s*/).reject(&:blank?)
  end

  def commontator_simple_format(text, html_options = {}, options = {})
    wrapper_tag = options.fetch(:wrapper_tag, :p)

    text = sanitize(text) if options.fetch(:sanitize, true)
    paragraphs = commontator_split_paragraphs(text)

    if paragraphs.empty?
      content_tag(wrapper_tag, nil, html_options)
    else
      paragraphs.map! do |paragraph|
        paragraph.starts_with?('<') && paragraph.ends_with?('>') ?
          raw(paragraph) : content_tag(wrapper_tag, raw(paragraph), html_options)
      end.join("\n").html_safe
    end
  end
end

ActiveSupport.on_load :action_controller do
  include Commontator::SharedHelper
end

ActiveSupport.on_load :action_controller_base do
  helper Commontator::SharedHelper
end
