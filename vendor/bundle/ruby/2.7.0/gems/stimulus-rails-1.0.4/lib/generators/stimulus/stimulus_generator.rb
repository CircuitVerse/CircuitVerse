require "rails/generators/named_base"

class StimulusGenerator < Rails::Generators::NamedBase # :nodoc:
  source_root File.expand_path("templates", __dir__)

  def copy_view_files
    @attribute = stimulus_attribute_value(controller_name)
    template "controller.js", "app/javascript/controllers/#{controller_name}_controller.js"
    rails_command "stimulus:manifest:update" unless Rails.root.join("config/importmap.rb").exist?
  end

  private
    def controller_name
      name.underscore.gsub(/_controller$/, "")
    end

    def stimulus_attribute_value(controller_name)
      controller_name.gsub(/\//, "--").gsub("_", "-")
    end
end
