# frozen_string_literal: true

class Avo::Actions::ExportAhoyVisits < Avo::BaseAction
  self.name = "Export Visits"
  self.message = "Export selected visits to CSV"
  self.confirm_button_label = "Export"
  self.cancel_button_label = "Cancel"
  self.no_confirmation = false

  def handle(query:, _fields:, _current_user:, _resource:, **)
    filename = "ahoy_visits_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"

    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["ID", "Visit Token", "User ID", "IP", "Browser", "OS", "Device", "Country", "Started At"]

      query.each do |record|
        csv << csv_row(record)
      end
    end

    download csv_data, filename

    succeed "Exported #{query.count} visits"
  end

  private

    def csv_row(record)
      [
        record.id,
        record.visit_token,
        record.user_id,
        record.ip,
        record.browser,
        record.os,
        record.device_type,
        record.country,
        record.started_at&.strftime("%Y-%m-%d %H:%M:%S")
      ]
    end
end
