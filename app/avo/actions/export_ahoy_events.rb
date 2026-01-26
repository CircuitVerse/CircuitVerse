# frozen_string_literal: true

class Avo::Actions::ExportAhoyEvents < Avo::BaseAction
  self.name = "Export Events"
  self.message = "Export selected events to CSV"
  self.confirm_button_label = "Export"
  self.cancel_button_label = "Cancel"
  self.no_confirmation = false

  # rubocop:disable Metrics/MethodLength
  def handle(query:, _fields:, _current_user:, _resource:, **)
    filename = "ahoy_events_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"

    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["ID", "Name", "Visit ID", "User ID", "Time", "Properties"]

      query.each do |record|
        csv << [
          record.id,
          record.name,
          record.visit_id,
          record.user_id,
          record.time&.strftime("%Y-%m-%d %H:%M:%S"),
          record.properties&.to_json
        ]
      end
    end

    download csv_data, filename

    succeed "Exported #{query.count} events"
  end
  # rubocop:enable Metrics/MethodLength
end
