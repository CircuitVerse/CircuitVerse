# frozen_string_literal: true

class Avo::Resources::MaintenanceTasksRun < Avo::BaseResource
  self.title = :task_name
  self.includes = []
  self.model_class = ::MaintenanceTasks::Run

  # rubocop:disable Metrics/MethodLength
  def fields
    field :id, as: :id, link_to_resource: true
    field :task_name, as: :text, sortable: true
    field :status, as: :badge, sortable: true do
      color = case record.status
              when "enqueued" then :info
              when "running" then :warning
              when "succeeded" then :success
              when "interrupted", "errored", "cancelled" then :error
              else :neutral
      end
      { label: record.status, color: color }
    end

    field :started_at, as: :date_time, sortable: true
    field :ended_at, as: :date_time, sortable: true
    field :time_running, as: :number, sortable: true
    field :tick_count, as: :number, sortable: true
    field :tick_total, as: :number, sortable: true
    field :job_id, as: :text, sortable: true
    field :cursor, as: :text

    field :error_class, as: :text
    field :error_message, as: :textarea
    field :backtrace, as: :textarea

    field :arguments, as: :textarea
    field :metadata, as: :textarea
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
