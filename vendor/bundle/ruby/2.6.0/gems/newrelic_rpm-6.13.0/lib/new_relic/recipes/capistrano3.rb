# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

require 'capistrano/framework'

namespace :newrelic do

  # notifies New Relic of a deployment
  desc "Record a deployment in New Relic (newrelic.com)"
  task :notice_deployment do
    if fetch(:newrelic_role)
      on roles(fetch(:newrelic_role)) do
        send_deployment_notification_to_newrelic
      end
    else
      run_locally do
        send_deployment_notification_to_newrelic
      end
    end
  end

  def send_deployment_notification_to_newrelic
    environment = fetch(:newrelic_rails_env, fetch(:rack_env, fetch(:rails_env, fetch(:stage, "production"))))

    require 'new_relic/cli/command.rb'

    begin
      # allow overrides to be defined for revision, description, changelog, appname, and user
      rev         = fetch(:newrelic_revision)
      description = fetch(:newrelic_desc)
      changelog   = fetch(:newrelic_changelog)
      appname     = fetch(:newrelic_appname)
      user        = fetch(:newrelic_user)
      license_key = fetch(:newrelic_license_key)

      has_scm_from_plugin = respond_to?(:scm_plugin_installed?) && scm_plugin_installed?
      has_scm_from_config = defined?(scm) && !scm.nil? && scm != :none

      if has_scm_from_plugin || has_scm_from_config
        changelog ||= lookup_changelog
        rev       ||= fetch(:current_revision)
      end

      new_revision = rev
      deploy_options = {
        :environment => environment,
        :revision    => new_revision,
        :changelog   => changelog,
        :description => description,
        :appname     => appname,
        :user        => user,
        :license_key => license_key
      }

      debug "Uploading deployment to New Relic"
      deployment = NewRelic::Cli::Deployments.new deploy_options
      deployment.run
      info "Uploaded deployment information to New Relic"

    rescue NewRelic::Cli::Command::CommandFailure => e
      info e.message
    rescue => e
      info "Error creating New Relic deployment (#{e})\n#{e.backtrace.join("\n")}"
    end
  end

  def lookup_changelog
    previous_revision = fetch(:previous_revision)
    current_revision = fetch(:current_revision)
    return unless current_revision && previous_revision

    debug "Retrieving changelog for New Relic Deployment details"

    if Rake::Task.task_defined?("git:check")
      log_command = "git --no-pager log --no-color --pretty=format:'  * %an: %s' " +
                    "--abbrev-commit --no-merges #{previous_revision}..#{current_revision}"
      `#{log_command}`
    end
  end
end
