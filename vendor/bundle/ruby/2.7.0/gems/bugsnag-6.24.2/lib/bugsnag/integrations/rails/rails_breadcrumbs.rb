require "bugsnag/breadcrumbs/breadcrumbs"

module Bugsnag::Rails
  DEFAULT_RAILS_BREADCRUMBS = [
    {
      :id => "perform_action.action_cable",
      :message => "Perform ActionCable",
      :type => Bugsnag::Breadcrumbs::PROCESS_BREADCRUMB_TYPE,
      :allowed_data => [
        :channel_class,
        :action
      ]
    },
    {
      :id => "perform_start.active_job",
      :message => "Start perform ActiveJob",
      :type => Bugsnag::Breadcrumbs::PROCESS_BREADCRUMB_TYPE,
      :allowed_data => []
    },
    {
      :id => "cache_read.active_support",
      :message => "Read cache",
      :type => Bugsnag::Breadcrumbs::PROCESS_BREADCRUMB_TYPE,
      :allowed_data => [
        :hit,
        :super_operation
      ]
    },
    {
      :id => "cache_fetch_hit.active_support",
      :message => "Fetch cache hit",
      :type => Bugsnag::Breadcrumbs::PROCESS_BREADCRUMB_TYPE,
      :allowed_data => []
    },
    {
      :id => "sql.active_record",
      :message => "ActiveRecord SQL query",
      :type => Bugsnag::Breadcrumbs::PROCESS_BREADCRUMB_TYPE,
      :allowed_data => [
        :name,
        # :connection_id is no longer provided in Rails 6.1+ but we can get it
        # from the :connection key of the event instead
        :connection_id,
        :cached
      ]
    },
    {
      :id => "start_processing.action_controller",
      :message => "Controller started processing",
      :type => Bugsnag::Breadcrumbs::REQUEST_BREADCRUMB_TYPE,
      :allowed_data => [
        :controller,
        :action,
        :method,
        :path
      ]
    },
    {
      :id => "process_action.action_controller",
      :message => "Controller action processed",
      :type => Bugsnag::Breadcrumbs::REQUEST_BREADCRUMB_TYPE,
      :allowed_data => [
        :controller,
        :action,
        :method,
        :status,
        :db_runtime
      ]
    },
    {
      :id => "redirect_to.action_controller",
      :message => "Controller redirect",
      :type => Bugsnag::Breadcrumbs::REQUEST_BREADCRUMB_TYPE,
      :allowed_data => [
        :status,
        :location
      ]
    },
    {
      :id => "halted_callback.action_controller",
      :message => "Controller halted via callback",
      :type => Bugsnag::Breadcrumbs::REQUEST_BREADCRUMB_TYPE,
      :allowed_data => [
        :filter
      ]
    },
    {
      :id => "render_template.action_view",
      :message => "ActionView template rendered",
      :type => Bugsnag::Breadcrumbs::REQUEST_BREADCRUMB_TYPE,
      :allowed_data => [
        :identifier,
        :layout
      ]
    },
    {
      :id => "render_partial.action_view",
      :message => "ActionView partial rendered",
      :type => Bugsnag::Breadcrumbs::REQUEST_BREADCRUMB_TYPE,
      :allowed_data => [
        :identifier
      ]
    },
    {
      :id => "deliver.action_mailer",
      :message => "ActionMail delivered",
      :type => Bugsnag::Breadcrumbs::REQUEST_BREADCRUMB_TYPE,
      :allowed_data => [
        :mailer,
        :message_id,
        :from,
        :date,
        :perform_deliveries
      ]
    }
  ]
end
