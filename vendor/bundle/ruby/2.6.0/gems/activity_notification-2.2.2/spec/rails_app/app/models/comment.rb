module CommentModel
  extend ActiveSupport::Concern

  included do
    belongs_to :article
    belongs_to :user
    validates :article, presence: true
    validates :user, presence: true

    acts_as_notifiable :users,
      targets: ->(comment, key) { ([comment.article.user] + comment.article.reload.commented_users.to_a - [comment.user]).uniq },
      group: :article, notifier: :user, email_allowed: true,
      action_cable_allowed: true, action_cable_api_allowed: true,
      parameters: { 'test_default_param' => '1' },
      notifiable_path: :article_notifiable_path,
      printable_name: ->(comment) { "comment \"#{comment.body}\"" },
      dependent_notifications: :update_group_and_delete_all

    require 'custom_optional_targets/console_output'
    optional_targets = {}
    # optional_targets = optional_targets.merge(CustomOptionalTarget::ConsoleOutput => {})
    if ENV['OPTIONAL_TARGET_AMAZON_SNS']
      require 'activity_notification/optional_targets/amazon_sns'
      if ENV['OPTIONAL_TARGET_AMAZON_SNS_TOPIC_ARN']
        optional_targets = optional_targets.merge(
          ActivityNotification::OptionalTarget::AmazonSNS => { topic_arn: ENV['OPTIONAL_TARGET_AMAZON_SNS_TOPIC_ARN'] }
        )
      elsif ENV['OPTIONAL_TARGET_AMAZON_SNS_PHONE_NUMBER']
        optional_targets = optional_targets.merge(
          ActivityNotification::OptionalTarget::AmazonSNS => { phone_number: :phone_number }
        )
      end
    end
    if ENV['OPTIONAL_TARGET_SLACK']
      require 'activity_notification/optional_targets/slack'
      optional_targets = optional_targets.merge(
        ActivityNotification::OptionalTarget::Slack  => {
          webhook_url: ENV['OPTIONAL_TARGET_SLACK_WEBHOOK_URL'], target_username: :slack_username,
          channel:  ENV['OPTIONAL_TARGET_SLACK_CHANNEL']  || 'activity_notification',
          username: 'ActivityNotification', icon_emoji: ":ghost:"
        }
      )
    end
    acts_as_notifiable :admins,
      targets: ->(comment) { Admin.all.to_a },
      group: :article, notifier: :user, notifiable_path: :article_notifiable_path,
      action_cable_allowed: true, action_cable_api_allowed: true,
      tracked: Rails.env.test? ? {only: []} : { only: [:create], action_cable_rendering: { fallback: :default } },
      printable_name: ->(comment) { "comment \"#{comment.body}\"" },
      dependent_notifications: :delete_all,
      optional_targets: optional_targets

    acts_as_group
  end

  def article_notifiable_path
    article_path(article)
  end

  def author?(user)
    self.user == user
  end
end

unless ENV['AN_TEST_DB'] == 'mongodb'
  class Comment < ActiveRecord::Base
    include CommentModel
  end
else
  require 'mongoid'
  class Comment
    include Mongoid::Document
    include Mongoid::Timestamps
    include GlobalID::Identification

    field :body,  type: String

    include ActivityNotification::Models
    include CommentModel
  end
end
