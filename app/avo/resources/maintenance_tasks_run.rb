# frozen_string_literal: true

class Avo::Resources::MaintenanceTasksRun < Avo::BaseResource
  self.title = :task_name
  self.includes = []
  self.model_class = ::MaintenanceTasks::Run

  # rubocop:disable Metrics/MethodLength
  def fields
    field :id, as: :id, link_to_resource: true
    field :task_name, as: :text, readonly: true, sortable: true
    field :status, as: :badge, readonly: true, sortable: true do
      color = case record.status
              when "enqueued" then :info
              when "running" then :warning
              when "succeeded" then :success
              when "interrupted", "errored", "cancelled" then :error
              else :neutral
      end
      { label: record.status, color: color }
    end

    field :started_at, as: :date_time, readonly: true, sortable: true
    field :ended_at, as: :date_time, readonly: true, sortable: true
    field :time_running, as: :number, readonly: true
    field :tick_count, as: :number, readonly: true
    field :tick_total, as: :number, readonly: true
    field :job_id, as: :text, readonly: true
    field :cursor, as: :text, readonly: true

    field :error_class, as: :text, readonly: true
    field :error_message, as: :textarea, readonly: true
    field :backtrace, as: :textarea, readonly: true

    field :arguments, as: :textarea, readonly: true
    field :metadata, as: :textarea, readonly: true

    field :created_at, as: :date_time, readonly: true, sortable: true
    field :updated_at, as: :date_time, readonly: true, sortable: true
  end

  # rubocop:enable Metrics/MethodLength
  def filters
    filter Avo::Filters::MaintenanceTasksStatus
    filter Avo::Filters::MaintenanceTasksName
    filter Avo::Filters::MaintenanceTasksCreatedAt
  end

  def actions
    action Avo::Actions::ExportMaintenanceTasksRuns
  end
end
