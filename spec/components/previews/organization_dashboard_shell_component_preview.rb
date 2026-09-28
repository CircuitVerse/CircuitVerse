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
      organization = build_org("CircuitVerse Community", "circuitverse-community", 1)
      other_org = build_org("Robotics Club", "robotics-club", 2)

      user_organizations = [
        { organization: organization, role: "admin", group_count: 3, member_count: 42 },
        { organization: other_org, role: "mentor", group_count: 1, member_count: 12 }
      ]

      render(OrganizationDashboardShellComponent.new(
               organization: organization,
               active_tab: active_tab,
               user_organizations: user_organizations,
               show_settings_tab: show_settings_tab
             )) do |component|
        component.with_tab_content do
          tag.p("Preview content for the #{active_tab.titleize} tab.")
        end
      end
    end

    def build_org(name, slug, id)
      org = Organization.new(name: name, slug: slug)
      org.define_singleton_method(:id) { id }
      org.define_singleton_method(:to_param) { slug }
      org
    end
end
