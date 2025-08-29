# config/initializers/view_component.rb
Rails.application.config.view_component.preview_paths ||= []
Rails.application.config.view_component.preview_paths << Rails.root.join("spec/components/previews")
Rails.application.config.view_component.default_preview_layout = "lookbook_preview"
