# frozen_string_literal: true

module GroupMembersHelper
  def membersCardViewerContainer(group)
    policy(group).admin_access? ? 'col-xs-12 col-sm-12 col-md-6 col-lg-4 groups-members-card-container' : 'col-xs-12 col-sm-12 col-md-6 col-lg-3 groups-members-card-container'
  end


  def membersCardViewer(group)
    policy(group).admin_access? ? 'groups-members-card' : 'groups-members-card-viewer'
  end

  def membersCardViewerDetail(group)
    policy(group).admin_access? ? 'col-7 groups-members-card-details' : 'col-11 groups-members-card-details groups-members-card-details-non-admin'
  end
end
