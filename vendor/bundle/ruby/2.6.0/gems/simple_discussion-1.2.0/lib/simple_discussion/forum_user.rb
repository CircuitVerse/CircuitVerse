module SimpleDiscussion
  module ForumUser
    extend ActiveSupport::Concern

    included do
      has_many :forum_threads
      has_many :forum_posts
      has_many :forum_subscriptions
    end
  end
end
