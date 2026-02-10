# frozen_string_literal: true

Avo.configure do |config|
  ## == Avo ==
  # Configure Avo's behavior here
  
  # Set the root path where Avo will be mounted
  config.root_path = '/avo_admin'
  
  # Set the current user method
  config.current_user_method = &:current_user
  
  # Set the user method for authentication
  config.authenticate_with do
    authenticate_user!
  end
  
  # Authorization
  config.authorization_methods = [Pundit.policy_scope]
  
  ## == Customization ==
  # Configure the look and feel
  config.app_name = 'CircuitVerse Admin'
  config.timezone = 'UTC'
  config.per_page = 50
  config.via_per_page = 8
  
  ## == Localization ==
  # Configure localization
  config.locale = :en
  
  ## == Features ==
  # Enable/disable features
  config.show_onboarding_cards = false
  config.main_menu = -> {
    "Dashboard" => "/avo_admin/resources",
    "Projects" => "/avo_admin/resources/projects",
    "Users" => "/avo_admin/resources/users",
    "Project Data" => "/avo_admin/resources/project_data",
    "Stars" => "/avo_admin/resources/stars",
    "Collaborations" => "/avo_admin/resources/collaborations"
  }
  
  ## == Resources ==
  # Configure which models to include
  config.models = {
    Project: 'Project',
    ProjectDatum: 'ProjectDatum',
    Star: 'Star',
    Collaboration: 'Collaboration',
    ProjectAccessType: 'ProjectAccessType',
    ProjectFeatured: 'ProjectFeatured',
    StarByUser: 'StarByUser',
    StarByProject: 'StarByProject'
  }
  
  ## == Security ==
  # Security settings
  config.id_links_to_resources = false
  config.raise_error_on_missing_policy = true
  
  ## == Performance ==
  # Performance optimizations
  config.cache_resources_on_index_view = true
  config.set_current_request_method = true
end
