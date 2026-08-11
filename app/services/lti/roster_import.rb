# frozen_string_literal: true

module Lti
  class RosterImport
    class << self
      # Members are whatever the caller decided belongs in the group; role
      # filtering is theirs. Returns the users added.
      def call(group, members, deployment)
        importable(members).filter_map { |member| add(group, member, deployment) }
      end

      private

        def importable(members)
          members.select do |member|
            member["status"] != "Inactive" && member["user_id"].present? &&
              member["email"].present?
          end
        end

        def add(group, member, deployment)
          user = user_for(member, deployment)
          return nil if group.primary_mentor_id == user.id

          # lti_synced is set on create only, so a member added by hand is never
          # marked as ours and cannot be removed by a later sync.
          GroupMember.create!(group: group, user: user, lti_synced: true) unless
            GroupMember.exists?(group: group, user: user)
          user
        rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
          nil
        end

        def user_for(member, deployment)
          uid = "#{deployment.id}:#{member['user_id']}"
          User.find_or_create_by!(provider: "lti", uid: uid) do |user|
            user.email = member["email"]
            user.name = member["name"].presence || member["email"]
            user.password = SecureRandom.hex(16)
            user.confirmed_at = Time.current
          end
        rescue ActiveRecord::RecordNotUnique
          User.find_by!(provider: "lti", uid: uid)
        end
    end
  end
end
