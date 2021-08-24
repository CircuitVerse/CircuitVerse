# Change the settings below to suit your needs
# All settings are initially set to their default values

# Note: Do not "return" from a Proc, use "next" instead if necessary
Commontator.configure do |config|
  # Engine Configuration

  # current_user_proc
  # Type: Proc
  # Arguments: the current controller (ActionController::Base)
  # Returns: the current user (acts_as_commontator)
  # The default works for Devise and similar authentication plugins
  # Default: ->(controller) { controller.current_user }
  config.current_user_proc = ->(controller) { controller.current_user }

  # javascript_proc
  # Type: Proc
  # Arguments: a view (ActionView::Base)
  # Returns: a String that is appended to Commontator JS views
  # Can be used, for example, to display/clear Rails error messages
  # or to reapply JQuery UI styles after Ajax calls
  # Objects visible in view templates can be accessed
  # through the view object (for example, view.flash)
  # However, the view does not include the main application's helpers
  # Default: ->(view) { '' }
  config.javascript_proc = ->(view) { '' }


  # User (acts_as_commontator) Configuration

  # user_name_proc
  # Type: Proc
  # Arguments: a user (acts_as_commontator)
  # Returns: the user's name (String)
  # Default: ->(user) { I18n.t('commontator.anonymous') } (all users are anonymous)
  config.user_name_proc = ->(user){ user.nil? ? I18n.t('commontator.anonymous') : user.name}

  # user_link_proc
  # Type: Proc
  # Arguments: a user (acts_as_commontator),
  #            the app_routes (ActionDispatch::Routing::RoutesProxy)
  # Returns: a path to the user's `show` page (String)
  # If anything non-blank is returned, the user's name in comments
  # comments will become a hyperlink pointing to this path
  # The main application's routes can be accessed through the app_routes object
  # Default: ->(user, app_routes) { '' } (no link)

  config.user_link_proc = ->(user, app_routes) { user.nil? ? '' : app_routes.user_path(user) }

  # user_avatar_proc
  # Type: Proc
  # Arguments: a user (acts_as_commontator), a view (ActionView::Base)
  # Returns: a String containing a HTML <img> tag pointing to the user's avatar image
  # The commontator_gravatar_image_tag helper takes a user object,
  # a border size and an options hash for Gravatar, and produces a Gravatar image tag
  # See available options at http://en.gravatar.com/site/implement/images/)
  # Note: Gravatar has several security implications for your users
  #       It makes your users trackable across different sites and
  #       allows de-anonymization attacks against their email addresses
  #       If you absolutely want to keep users' email addresses or identities secret,
  #       do not use Gravatar or similar services
  # Default: ->(user, view) {
  #   view.commontator_gravatar_image_tag(user, 1, s: 60, d: 'mm')
  # }
  config.user_avatar_proc = ->(user, view) {
    # image_tag(user.profile_picture.url(:thumb), { alt: user.name,
    #                  title: user.name,
    #                  border: 1 })
    return ActionController::Base.helpers.image_tag(user.profile_picture.url(:thumb));
    # puts view.commontator_gravatar_image_tag(user, 1, s: 60, d: 'mm')
    # view.commontator_gravatar_image_tag(user, 1, s: 60, d: 'mm')
  }

  # user_email_proc
  # Type: Proc
  # Arguments: a user (acts_as_commontator), a mailer (ActionMailer::Base)
  # Returns: the user's email address (String)
  # The default works for Devise's defaults
  # If the mailer argument is nil, Commontator intends to hash the email and send the hash
  # to Gravatar, so you should always return the user's email address (if using Gravatar)
  # If the mailer argument is not nil, then Commontator intends to send an email to
  # the address returned; you can prevent it from being sent by returning a blank String
  # Default: ->(user, mailer) { user.try(:email) || '' }
  config.user_email_proc = ->(user, mailer) { user.try(:email) || '' }



  # Thread/Commontable (acts_as_commontable) Configuration

  # comment_filter
  # Type: Arel node (Arel::Nodes::Node) or nil
  # Arel that filters visible comments
  # If specified, visible comments will be filtered according to this Arel node
  # A value of nil will cause no filtering to be done
  # Moderators can manually override this filter for themselves
  # Example: Commontator::Comment.arel_table[:deleted_at].eq(nil) (hides deleted comments)
  #          This is not recommended, as it can cause confusion over deleted comments
  #          If using pagination, it can also cause comments to change pages
  # Default: nil (no filtering - all comments are visible)
  config.comment_filter = nil

  # thread_read_proc
  # Type: Proc
  # Arguments: a thread (Commontator::Thread), a user (acts_as_commontator)
  # Returns: a Boolean, true if and only if the user should be allowed to read that thread
  # Note: can be called with a user object that is nil (if they are not logged in)
  # Default: ->(thread, user) { true } (anyone can read any thread)
  config.thread_read_proc = ->(thread, user) { 
    return true if thread.commontable.public?

    ProjectPolicy.new(user, thread.commontable).check_view_access?
  }

  # thread_moderator_proc
  # Type: Proc
  # Arguments: a thread (Commontator::Thread), a user (acts_as_commontator)
  # Returns: a Boolean, true if and only if the user is a moderator for that thread
  # If you want global moderators, make this proc true for them regardless of thread
  # Default: ->(thread, user) { false } (no moderators)
  config.thread_moderator_proc = ->(thread, user) { user.admin? }

  # comment_editing
  # Type: Symbol
  # Whether users can edit their own comments
  # Valid options:
  #   :a (always)
  #   :l (only if it's the latest comment)
  #   :n (never)
  # Default: :l
  config.comment_editing = :a

  # comment_deletion
  # Type: Symbol
  # Whether users can delete their own comments
  # Valid options:
  #   :a (always)
  #   :l (only if it's the latest comment)
  #   :n (never)
  # Note: For moderators, see the next option
  # Default: :l
  config.comment_deletion = :a

  # moderator_permissions
  # Type: Symbol
  # What permissions moderators have
  # Valid options:
  #   :e (delete and edit comments and close threads)
  #   :d (delete comments and close threads)
  #   :c (close threads only)
  # Default: :d
  config.moderator_permissions = :d

  # comment_voting
  # Type: Symbol
  # Whether users can vote on other users' comments
  # Valid options:
  #   :n  (no voting)
  #   :l  (likes - requires acts_as_votable gem)
  #   :ld (likes/dislikes - requires acts_as_votable gem)
  # Not yet implemented:
  #   :s  (star ratings)
  #   :r  (reputation system)
  # Default: :n
  config.comment_voting = :ld

  # vote_count_proc
  # Type: Proc
  # Arguments: a thread (Commontator::Thread), pos (Fixnum), neg (Fixnum)
  # Returns: vote count to be displayed (String)
  # pos is the number of likes, or the rating, or the reputation
  # neg is the number of dislikes, if applicable, or 0 otherwise
  # Default: ->(thread, pos, neg) { "%+d" % (pos - neg) }
  config.vote_count_proc = ->(thread, pos, neg) { "%+d" % (pos - neg) }

  # comment_order
  # Type: Symbol
  # What order to use for comments
  # Valid options:
  #   :e  (earliest comment first)
  #   :l  (latest comment first)
  #   :ve (highest voted first; earliest first if tied)
  #   :vl (highest voted first; latest first if tied)
  # Notes:
  #   :e is usually used in forums (discussions)
  #   :l is usually used in blogs (opinions)
  #   :ve and :vl are usually used where it makes sense to rate comments
  #     based on usefulness (q&a, reviews, guides, etc.)
  # If :l is selected, the "reply to thread" form will appear before the comments
  # Otherwise, it will appear after the comments
  # Default: :e
  config.comment_order = :e

  # new_comment_style
  # Type: Symbol
  # How to display the "new comment" form
  # Valid options:
  #   :t (always present in the thread's page)
  #   :l (link to the form; opens in the same page using JS)
  # Not yet implemented:
  #   :n (link to the form; opens in a new window)
  # Default: :l
  config.new_comment_style = :l

  # comments_per_page
  # Type: Array
  # The array represents how many comments to load at each nesting level, with the
  # first number corresponding to the current level, the second number to the next level, etc
  # Note: large values WILL cause performance and memory issues with many nested comments
  # The maximum number of comments loaded at once for the default setting is:
  # 20 + 20*5 + 20*5*2 == 320
  # Default: [ 20, 5, 2 ]
  config.comments_per_page = [ 20, 5, 2]

  # thread_subscription
  # Type: Symbol
  # Whether users can subscribe to threads to receive activity email notifications
  # Valid options:
  #   :n (no subscriptions)
  #   :a (automatically subscribe when you comment; cannot do it manually)
  #   :m (manual subscriptions only)
  #   :b (both automatic, when commenting, and manual)
  # Default: :n
  config.thread_subscription = :b

  # email_from_proc
  # Type: Proc
  # Arguments: a thread (Commontator::Thread)
  # Returns: the address emails are sent "from" (String)
  # Important: If using subscriptions, change this to at least match your domain name
  # Default: ->(thread) {
  #   "no-reply@#{Rails.application.class.parent.to_s.downcase}.com"
  # }
  config.email_from_proc = ->(thread) {
    # "no-reply@#{Rails.application.class.parent.to_s.downcase}.com"
    return "#{ENV["CIRCUITVERSE_EMAIL_ID"]}"
  }

  # commontable_name_proc
  # Type: Proc
  # Arguments: a thread (Commontator::Thread)
  # Returns: a name that refers to the commontable object (String)
  # If you have multiple commontable models, you can also pass this
  # configuration value as an argument to acts_as_commontable for each one
  # Default: ->(thread) {
  #                   "#{thread.commontable.class.name} ##{thread.commontable.id}" }
  config.commontable_name_proc = ->(thread) {
    "#{thread.commontable.class.name} ##{thread.commontable.id}" }

  # comment_url_proc
  # Type: Proc
  # Arguments: a comment (Commontator::Comment),
  #            the app_routes (ActionDispatch::Routing::RoutesProxy)
  # Returns: a String containing the url of the view that displays the given comment
  # This usually is the commontable's "show" page
  # The main application's routes can be accessed through the app_routes object
  # Default: ->(comment, app_routes) {
  #   app_routes.polymorphic_url(comment.thread.commontable, anchor: "comment_#{comment.id}_div")
  # }
  # (defaults to the commontable's show url with an anchor pointing to the comment's div)
  config.comment_url_proc = ->(comment, app_routes) {
    if comment.thread.commontable.class.name == "Project"
      project = comment.thread.commontable
      author = project.author
      return "#{Rails.configuration.site_url}users/#{author.id}/projects/#{project.id}#comment_#{comment.id}_div"
    else
      return app_routes.polymorphic_url(comment.thread.commontable, anchor: "comment_#{comment.id}_div")
    end
  }

  # mentions_enabled
  # Type: Boolean
  # Whether users can mention other users to subscribe them to the thread
  # Valid options:
  #   false (no mentions)
  #   true  (mentions enabled)
  # Default: false
  config.mentions_enabled = true

  # user_mentions_proc
  # Type: Proc
  # Arguments:
  #   the current user (acts_as_commontator)
  #   the current thread (Commontator::Thread)
  #   the search query inputted by user (String)
  # Returns: an ActiveRecord Relation object
  # Important notes:
  #
  #  - The proc will be called internally with an empty search string.
  #    In that case, it MUST return all users that can be mentioned.
  #
  #  - With mentions enabled, any registered user in your app is able
  #    to call this proc with any search query >= 3 characters.
  #    Make sure to handle SQL escaping properly and that the
  #    attribute being searched does not contain sensitive information.
  #
  # Default: ->(current_user, query) {
  #   current_user.class.where('username LIKE ?', "#{query}%")
  # }
  config.user_mentions_proc = ->(current_user, thread, query) {
    current_user.class.where('name LIKE ?', "#{query}%")
  }
end
