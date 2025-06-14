# frozen_string_literal: true

module LayoutComponents
  class NotificationComponent < ViewComponent::Base
    def initialize(current_user: nil)
      super
      @current_user = current_user
    end

    private

      attr_reader :current_user

      def user_signed_in?
        current_user.present?
      end

      def unread_notifications
        @unread_notifications ||= notifications_scope.unread
      end

      def recent_notifications
        @recent_notifications ||= notifications_scope.newest_first.limit(5)
      end

      def notifications_scope
        return NoticedNotification.none unless current_user

        NoticedNotification.where(recipient: current_user)
      end
  end
end
