# frozen_string_literal: true

module Lti
  class RosterDrop
    class << self
      # Removes memberships this deployment created for people the roster no
      # longer lists. Returns the users removed.
      def call(group, members, deployment)
        keep = enrolled_uids(members, deployment)
        prefix = "#{deployment.id}:"

        ours(group).reject { |gm| keep.include?(gm.user.uid) }
                   .select { |gm| gm.user.uid.to_s.start_with?(prefix) }
                   .map { |gm| gm.user.tap { gm.destroy } }
      end

      private

        def enrolled_uids(members, deployment)
          members.filter_map do |member|
            "#{deployment.id}:#{member['user_id']}" if member["status"] != "Inactive" &&
                                                       member["user_id"].present?
          end.to_set
        end

        def ours(group)
          group.group_members.where(lti_synced: true).includes(:user)
        end
    end
  end
end
