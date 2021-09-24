class Commontator::Thread < ActiveRecord::Base
  belongs_to :closer, polymorphic: true, optional: true
  belongs_to :commontable, polymorphic: true, optional: true, inverse_of: :commontator_thread

  has_many :comments, dependent: :destroy, inverse_of: :thread
  has_many :subscriptions, dependent: :destroy, inverse_of: :thread

  validates :commontable, presence: true, unless: :is_closed?
  validates :commontable_id, uniqueness: { scope: :commontable_type, allow_nil: true }

  def config
    @config ||= commontable.try(:commontable_config) || Commontator
  end

  def is_votable?
    config.comment_voting.to_sym != :n
  end

  def is_filtered?
    !config.comment_filter.nil?
  end

  def filtered_comments(show_all)
    return comments if show_all

    cf = config.comment_filter
    return comments if cf.nil?

    comments.where(cf)
  end

  def ordered_comments(show_all)
    fc = filtered_comments(show_all)
    cc = Commontator::Comment.arel_table

    # ID is used as a tie-breaker because MySQL lacks sub-second timestamp resolution
    case config.comment_order.to_sym
    when :l
      fc.order(cc[:created_at].desc, cc[:id].desc)
    when :ve
      fc.order(
        Arel::Nodes::Descending.new(cc[:cached_votes_up] - cc[:cached_votes_down]),
        cc[:created_at].asc,
        cc[:id].asc
      )
    when :vl
      fc.order(
        Arel::Nodes::Descending.new(cc[:cached_votes_up] - cc[:cached_votes_down]),
        cc[:created_at].desc,
        cc[:id].desc
      )
    else
      fc.order(cc[:created_at].asc, cc[:id].asc)
    end
  end

  def latest_comment(show_all)
    @latest_comment ||= ordered_comments(show_all).last
  end

  def comments_with_parent_id(parent_id, show_all)
    oc = ordered_comments(show_all)

    if [ :i, :b ].include?(config.comment_reply_style)
      # Filter comments by parent_id so we display nested comments
      oc.where(parent_id: parent_id)
    elsif parent_id.nil?
      # Parent is the thread itself and nesting is disabled, so include all comments
      oc
    else
      # Parent is some comment and nesting is disabled, so return nothing
      oc.none
    end
  end

  def paginated_comments(page, parent_id, show_all)
    cp = comments_with_parent_id(parent_id, show_all)

    cp.paginate(page: page, per_page: config.comments_per_page[0])
  end

  def nest_comments(
    comments, root_per_page, per_page_by_parent_id, count_by_parent_id, children_by_parent_id
  )
    comments.map do |comment|
      # Delete is used to ensure loops don't cause stack overflow
      children = children_by_parent_id.delete(comment.id) || []
      count = count_by_parent_id.delete(comment.id) || 0
      per_page = per_page_by_parent_id.delete(comment.id) || 0
      nested_children = nest_comments(
        children, root_per_page, per_page_by_parent_id, count_by_parent_id, children_by_parent_id
      )

      [ comment, Commontator::Collection.new(nested_children, count, root_per_page, per_page) ]
    end
  end

  def nested_comments_for(user, comments, show_all)
    includes = [ :thread, :creator, :editor ]
    total_entries = comments.total_entries
    root_per_page = config.comments_per_page[0]
    current_page = comments.current_page.to_i
    comments = comments.includes(includes).to_a
    count_by_parent_id = {}
    per_page_by_parent_id = {}
    children_by_parent_id = Hash.new { |hash, key| hash[key] = [] }

    if [ :i, :b ].include? config.comment_reply_style
      all_parent_ids = comments.map(&:id)
      (config.comments_per_page[1..-1] + [ 0 ]).each_with_index do |per_page, index|
        filtered_comments(show_all).where(parent_id: all_parent_ids)
                                   .group(:parent_id)
                                   .count
                                   .each do |parent_id, count|
          count_by_parent_id[parent_id] = count
          per_page_by_parent_id[parent_id] = per_page
        end

        next if per_page == 0

        children = all_parent_ids.empty? ? [] : Commontator::Comment.find_by_sql(
          all_parent_ids.map do |parent_id|
            Commontator::Comment.select(Arel.star).from(
              Arel::Nodes::TableAlias.new(
                Arel::Nodes::Grouping.new(
                  Arel::Nodes::SqlLiteral.new(
                    ordered_comments(show_all).where(parent_id: parent_id).limit(per_page).to_sql
                  )
                ), :commontator_comments
              )
            ).to_sql
          end.reduce { |memo, sql| memo.nil? ? sql : "#{memo} UNION ALL #{sql}" }
        )
        children.each { |comment| children_by_parent_id[comment.parent_id] << comment }
        all_parent_ids = children.map(&:id)
      end
    end

    Commontator::Collection.new(
      nest_comments(
        comments, root_per_page, per_page_by_parent_id, count_by_parent_id, children_by_parent_id
      ),
      total_entries,
      root_per_page,
      root_per_page,
      current_page
    ).tap do |nested_comments|
      next unless is_votable?

      ActiveRecord::Associations::Preloader.new.preload(
        nested_comments.flatten, :votes_for, ActsAsVotable::Vote.where(voter: user)
      )
    end
  end

  def new_comment_page(parent_id, show_all)
    per_page = config.comments_per_page[0].to_i
    return 1 if per_page <= 0

    comment_order = config.comment_order.to_sym
    return 1 if comment_order == :l

    cp = comments_with_parent_id(parent_id, show_all)
    cc = Commontator::Comment.arel_table
    comment_index = case config.comment_order.to_sym
    when :l
      1 # First comment
    when :ve
      # Last comment with rating == 0
      cp.where((cc[:cached_votes_up] - cc[:cached_votes_down]).gteq(0)).count
    when :vl
      # First comment with rating == 0
      cp.where((cc[:cached_votes_up] - cc[:cached_votes_down]).gt(0)).count + 1
    else
      cp.count # Last comment
    end

    (comment_index.to_f/per_page).ceil
  end

  def is_closed?
    !closed_at.nil?
  end

  def close(user = nil)
    return false if is_closed?

    self.closed_at = Time.now
    self.closer = user
    save
  end

  def reopen
    return false unless is_closed? && !commontable.nil?

    self.closed_at = nil
    save
  end

  def subscribers
    subscriptions.map(&:subscriber)
  end

  def subscription_for(subscriber)
    return nil if !subscriber || !subscriber.is_commontator

    subscriber.commontator_subscriptions.find_by(thread_id: self.id)
  end

  def subscribe(subscriber)
    return false unless subscriber.is_commontator && !subscription_for(subscriber)

    subscription = Commontator::Subscription.new
    subscription.subscriber = subscriber
    subscription.thread = self
    subscription.save
  end

  def unsubscribe(subscriber)
    subscription = subscription_for(subscriber)
    return false unless subscription

    subscription.destroy
  end

  def mark_as_read_for(subscriber)
    subscription = subscription_for(subscriber)
    return false unless subscription

    subscription.touch
  end

  # Creates a new empty thread and assigns it to the commontable
  # The old thread is kept in the database for archival purposes
  def clear
    return if commontable.nil? || !is_closed?

    new_thread = Commontator::Thread.new
    new_thread.commontable = commontable

    with_lock do
      self.commontable = nil
      save!
      new_thread.save!
      Commontator::Subscription.where(thread: self).update_all(thread_id: new_thread.id)
    end
  end

  ##################
  # Access Control #
  ##################

  # Reader capabilities (user can be nil or false)
  def can_be_read_by?(user)
    return true if can_be_edited_by?(user)

    !commontable.nil? && config.thread_read_proc.call(self, user)
  end

  # Thread moderator capabilities
  def can_be_edited_by?(user)
    !commontable.nil? && !user.nil? && user.is_commontator &&
    config.thread_moderator_proc.call(self, user)
  end

  def can_subscribe?(user)
    thread_sub = config.thread_subscription.to_sym
    !is_closed? && !user.nil? && user.is_commontator &&
    (thread_sub == :m || thread_sub == :b) && can_be_read_by?(user)
  end
end
