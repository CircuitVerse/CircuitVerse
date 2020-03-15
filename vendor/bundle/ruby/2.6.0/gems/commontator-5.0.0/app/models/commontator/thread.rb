module Commontator
  class Thread < ActiveRecord::Base
    belongs_to :closer, polymorphic: true, optional: true
    belongs_to :commontable, polymorphic: true, optional: true

    has_many :comments, dependent: :destroy
    has_many :subscriptions, dependent: :destroy

    validates_presence_of :commontable, unless: :is_closed?
    validates_uniqueness_of :commontable_id,
                            scope: :commontable_type,
                            allow_nil: true

    def config
      @config ||= commontable.try(:commontable_config) || Commontator
    end

    def will_paginate?
      return false if config.comments_per_page.nil? || !comments.respond_to?(:paginate)
      require 'commontator/link_renderer'
      true
    end

    def is_filtered?
      will_paginate? || config.comment_filter
    end

    def filtered_comments
      cf = config.comment_filter
      return comments if cf.nil?
      comments.where(cf)
    end

    def ordered_comments(unfiltered = false)
      vc = unfiltered ? comments : filtered_comments
      case config.comment_order.to_sym
      when :l then vc.order('created_at DESC')
      when :e then vc.order('created_at ASC')
      when :ve then vc.order('cached_votes_down - cached_votes_up', 'created_at ASC')
      when :vl then vc.order('cached_votes_down - cached_votes_up', 'created_at DESC')
      else vc
      end
    end

    def paginated_comments(page = 1, per_page = config.comments_per_page)
      oc = ordered_comments
      return oc unless will_paginate?
      oc.paginate(page: page, per_page: per_page)
    end

    def new_comment_page(per_page = config.comments_per_page)
      return 1 if per_page.nil? || per_page.to_i <= 0
      comment_index = \
        case config.comment_order.to_sym
        when :l
          1 # First comment
        when :ve
          comment_arel = Comment.arel_table
          # Last comment with rating = 0
          filtered_comments.where((comment_arel[:cached_votes_up] - comment_arel[:cached_votes_down]).gteq 0).count
        when :vl
          comment_arel = Comment.arel_table
          # First comment with rating = 0
          filtered_comments.where((comment_arel[:cached_votes_up] - comment_arel[:cached_votes_down]).gt 0).count + 1
        else
          filtered_comments.count # Last comment
        end
      (comment_index.to_f/per_page.to_i).ceil
    end

    def is_closed?
      !closed_at.blank?
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
      subscriptions.collect{|s| s.subscriber}
    end

    def subscription_for(subscriber)
      return nil if !subscriber || !subscriber.is_commontator
      subscriber.subscriptions.where(thread_id: self.id).first
    end

    def subscribe(subscriber)
      return false unless subscriber.is_commontator && !subscription_for(subscriber)
      subscription = Subscription.new
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
      return if commontable.blank? || !is_closed?
      new_thread = Thread.new
      new_thread.commontable = commontable

      with_lock do
        self.commontable = nil
        save!
        new_thread.save!
        subscriptions.each do |s|
          s.thread = new_thread
          s.save!
        end
      end
    end

    ##################
    # Access Control #
    ##################

    # Reader capabilities (user can be nil or false)
    def can_be_read_by?(user)
      return true if can_be_edited_by?(user)
      !commontable.nil? &&\
      config.thread_read_proc.call(self, user)
    end

    # Thread moderator capabilities
    def can_be_edited_by?(user)
      !commontable.nil? && !user.nil? && user.is_commontator &&\
      config.thread_moderator_proc.call(self, user)
    end

    def can_subscribe?(user)
      thread_sub = config.thread_subscription.to_sym
      !is_closed? && !user.nil? && user.is_commontator &&\
      (thread_sub == :m || thread_sub == :b) &&\
      can_be_read_by?(user)
    end
  end
end
