# frozen_string_literal: true

class OrganizationDashboardShellComponent < ViewComponent::Base
  renders_one :tab_content

  def initialize(organization:, active_tab:, user_organizations:, user_organizations_has_more:, show_settings_tab:)
    super()
    @organization = organization
    @active_tab = active_tab
    @user_organizations = user_organizations
    @user_organizations_has_more = user_organizations_has_more
    @show_settings_tab = show_settings_tab
  end

  def tab_class(tab)
    "nav-link #{'active' if @active_tab == tab}"
  end

  def show_settings_tab?
    @show_settings_tab
  end

  def initials(organization)
    organization.name.first.upcase
  end

  def current_org?(organization)
    organization.id == @organization.id
  end
end
