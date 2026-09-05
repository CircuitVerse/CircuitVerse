# frozen_string_literal: true

class OrganizationDashboardShellComponentPreview < ViewComponent::Preview
  def overview
    render_shell(active_tab: "overview", show_settings_tab: false)
  end

  def admin_overview
    render_shell(active_tab: "overview", show_settings_tab: true)
  end

  private

    def render_shell(active_tab:, show_settings_tab:)
      organization = Organization.new(
        name: "CircuitVerse Community",
        uuid: SecureRandom.uuid
      )
      render(OrganizationDashboardShellComponent.new(
               organization: organization,
               active_tab: active_tab,
               show_settings_tab: show_settings_tab
             )) do |component|
        component.with_tab_content do
          tag.p("Preview content for the #{active_tab.titleize} tab.")
        end
      end
    end
end
