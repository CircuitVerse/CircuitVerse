# frozen_string_literal: true

class Avo::Filters::MaintenanceTasksName < Avo::Filters::SelectFilter
  self.name = "Task Name"

  def apply(_request, query, value)
    return query if value.blank?

    query.where(task_name: value)
  end

  def options
    ::MaintenanceTasks::Run.distinct.pluck(:task_name).compact.sort.each_with_object({}) do |name, hash|
      hash[name] = name
    end
  end
end
