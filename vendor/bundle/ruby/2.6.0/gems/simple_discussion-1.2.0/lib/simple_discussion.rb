require 'font-awesome-sass'
require 'friendly_id'
require 'gravatar_image_tag'
require 'will_paginate'

require 'simple_discussion/engine'
require 'simple_discussion/forum_user'
require 'simple_discussion/slack'
require 'simple_discussion/version'
require 'simple_discussion/will_paginate'

module SimpleDiscussion
  # Define who owns the subscription
  mattr_accessor :send_email_notifications
  mattr_accessor :send_slack_notifications
  @@send_email_notifications = true
  @@send_slack_notifications = true

  def self.setup
    yield self
  end
end
