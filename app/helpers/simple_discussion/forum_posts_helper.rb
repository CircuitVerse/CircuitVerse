# frozen_string_literal: true

module SimpleDiscussion::ForumPostsHelper
  def formatted_content(text)
    options = %I[hard_wrap filter_html autolink tables]
    md = Redcarpet.new(text, *options).to_html
    sanitize(md)
  end

  def avatar_tag(email)
    image_tag gravatar_url_for(email, size: 40), class: "rounded avatar"
  end

  def category_link(category)
    link_to category.name, simple_discussion.forum_category_forum_threads_path(category),
    style: "color: #{category.color}" # rubocop:disable ArgumentAlignment, Migration/DepartmentName
  end

  def forum_post_classes(forum_post)
    klasses = %w[forum-post card mb-3]
    klasses << "solved" if forum_post.solved?
    klasses << "original-poster" if forum_post.user == @forum_thread.user # rubocop:disable Rails/HelperInstanceVariable
    klasses
  end

  def forum_user_badge(user)
    content_tag :span, "Mod", class: "badge badge-default" if user.respond_to?(:moderator) && user.moderator?
  end

  def gravatar_url_for(email, **options)
    hash = Digest::MD5.hexdigest(email&.downcase || "")
    options.reverse_merge!(default: :mp, rating: :pg, size: 48)
    "https://secure.gravatar.com/avatar/#{hash}.png?#{options.to_param}"
  end
end
