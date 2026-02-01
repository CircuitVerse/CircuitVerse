# frozen_string_literal: true

class Avo::Actions::ExportIssueCircuitData < Avo::BaseAction
  self.name = "Export Data"
  self.message = "Export selected issue circuit data records to CSV"
  self.confirm_button_label = "Export"
  self.cancel_button_label = "Cancel"
  self.no_confirmation = false

  def handle(query:, _fields:, _current_user:, _resource:, **)
    filename = "issue_circuit_data_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"

    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["ID", "Data Length", "Created At", "Updated At", "Data Preview"]

      query.each do |record|
        csv << [
          record.id,
          record.data&.length || 0,
          record.created_at&.strftime("%Y-%m-%d %H:%M:%S"),
          record.updated_at&.strftime("%Y-%m-%d %H:%M:%S"),
          record.data&.truncate(500) || ""
        ]
      end
    end

    download csv_data, filename

    succeed "Exported #{query.count} records"
  end
end
