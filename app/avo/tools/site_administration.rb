# frozen_string_literal: true

if defined?(Avo::BaseResourceTool)
  class Avo::Tools::SiteAdministration < Avo::BaseResourceTool
    self.name = "Site Administration"
    self.partial = "avo/tools/site_administration"
  end
else
  module Avo
    module Tools
      class SiteAdministration
      end
    end
  end
end
