# frozen_string_literal: true

class Avo::Actions::ExportNoticedNotifications < Avo::BaseAction
  self.name = "Export Notifications"
  self.message = "Export selected notifications to CSV"
  self.confirm_button_label = "Export"
  self.cancel_button_label = "Cancel"
  self.no_confirmation = false

  def handle(query:, _fields:, _current_user:, _resource:, **)
    filename = "noticed_notifications_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"

    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["ID", "Type", "Recipient Type", "Recipient ID", "Read At", "Created At", "Updated At", "Params"]

      query.each do |record|
        csv << csv_row(record)
      end
    end

    download csv_data, filename

    succeed "Exported #{query.count} notifications"
  end

  private

    def csv_row(record)
      [
        record.id,
        record.type,
        record.recipient_type,
        record.recipient_id,
        record.read_at&.strftime("%Y-%m-%d %H:%M:%S"),
        record.created_at&.strftime("%Y-%m-%d %H:%M:%S"),
        record.updated_at&.strftime("%Y-%m-%d %H:%M:%S"),
        record.params&.to_json
      ]
    end
end
