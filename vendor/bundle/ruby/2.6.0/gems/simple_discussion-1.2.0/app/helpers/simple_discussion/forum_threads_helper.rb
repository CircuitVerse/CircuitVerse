module SimpleDiscussion::ForumThreadsHelper
  # Used for flagging links in the navbar as active
  def forum_link_to(path, opts={}, &block)
    link_to path, class: forum_link_class(path, opts), &block
  end

  def forum_link_class(matches, opts={})
    case matches
    when Array
      "active" if matches.any?{ |m| request.path.starts_with?(m) }
    when String
      "active" if opts.fetch(:exact, false) ? request.path == matches : request.path.starts_with?(matches)
    end
  end

  # A nice hack to manipulate the layout so we can have sub-layouts
  # without any changes in the user's application.
  #
  # We use this for rendering the sidebar layout for all the forum pages
  #
  # https://mattbrictson.com/easier-nested-layouts-in-rails
  #
  def parent_layout(layout)
    @view_flow.set(:layout, output_buffer)
    output = render(file: "layouts/#{layout}")
    self.output_buffer = ActionView::OutputBuffer.new(output)
  end
end
