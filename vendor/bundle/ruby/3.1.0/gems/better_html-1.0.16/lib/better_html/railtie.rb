require 'better_html/better_erb'

class BetterHtml::Railtie < Rails::Railtie
  initializer "better_html.better_erb.initialization" do
    BetterHtml::BetterErb.prepend!
  end
end
