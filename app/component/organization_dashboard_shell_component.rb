# frozen_string_literal: true

class OrganizationDashboardShellComponent < ViewComponent::Base
  renders_one :tab_content

  def initialize(organization:, active_tab:)
    super()
    @organization = organization
    @active_tab = active_tab
  end

  def tab_class(tab)
    "nav-link #{'active' if @active_tab == tab}"
  end

  def show_settings_tab?
    helpers.policy(@organization).admin_access?
  end
end
