# frozen_string_literal: true

#
# == Schema Information
#
# Table name: stars
#
#  id         :bigint           not null, primary key
#  user_id    :bigint
#  project_id :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_stars_on_project_id  (project_id)
#  index_stars_on_user_id_and_project_id  (user_id,project_id) UNIQUE
#  index_stars_on_user_id     (user_id)

class Star < ApplicationRecord
  belongs_to :user
  belongs_to :project
  after_create_commit :notify_recipient
  before_destroy :cleanup_notification
  has_many :notifications, as: :notifiable # rubocop:disable Rails/HasManyOrHasOneDependent
  has_noticed_notifications model_name: "NoticedNotification"

  private

    # @return [void]
    def notify_recipient
      return if user.id == project.author_id

      StarNotification.with(user: user, project: project).deliver_later(project.author)
    end

    # @return [void]
    def cleanup_notification
      notifications_as_star.destroy_all
    end
end
