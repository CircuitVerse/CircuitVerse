# frozen_string_literal: true

module GroupMembersHelper
  def membersCardViewer(group)
    if policy(group).admin_access?
      return 'col-7 groups-members-card-details'
    else
      return 'col-11 groups-members-card-details groups-members-card-details-non-admin'
    end
  end
end
