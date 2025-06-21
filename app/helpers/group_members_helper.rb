# frozen_string_literal: true

module GroupMembersHelper
  # @param [Group] group
  # @return [String] CSS Class for group members card container
  def membersCardViewerContainer(group)
    if policy(group).admin_access?
      "col-12 col-sm-12 col-md-6 col-lg-4 groups-members-card-container"
    else
      "col-12 col-sm-12 col-md-6 col-lg-3 groups-members-card-container"
    end
  end

  # @param [Group] group
  # @return [String] CSS Class for group members card
  def membersCardViewer(group)
    policy(group).admin_access? ? "groups-members-card" : "groups-members-card-viewer"
  end

  # @param [Group] group
  # @return [String] CSS Class for group members card details
  def membersCardViewerDetail(group)
    if policy(group).admin_access?
      "col-6 groups-members-card-details"
    else
      "col-11 groups-members-card-details groups-members-card-details-non-admin"
    end
  end
end
