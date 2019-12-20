# frozen_string_literal: true
require "custom_optional_targets/web_push"

class Star < ApplicationRecord
  belongs_to :user
  belongs_to :project

  acts_as_notifiable :users,
                     # Notification targets as :targets is a necessary option
                     targets: ->(star, key) {
                       [star.project.author]
                     },
                     notifier: :user,
                     printable_name: ->(star) { "starred your project \"#{star.project.name}\"" },
                     notifiable_path: :star_notifiable_path,
                     optional_targets: {
                         CustomOptionalTarget::WebPush => {}
                     }

  def star_notifiable_path
    user_project_path(project.author, project)
  end
end
