# frozen_string_literal: true

class Avo::Dashboards::SiteAdministration < Avo::Dashboards::BaseDashboard
  self.id = "site_administration"
  self.name = "Site Administration"
  self.description = "Overview of all models in the system"
  self.grid_cols = 1

  def cards
    card Avo::Cards::ModelOverview
  end
end
