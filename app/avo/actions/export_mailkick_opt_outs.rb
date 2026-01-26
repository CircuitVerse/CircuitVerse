# frozen_string_literal: true

class Avo::Actions::ExportMailkickOptOuts < Avo::BaseAction
  self.name = "Export Opt-Outs"
  self.message = "Export selected opt-outs to CSV"
  self.confirm_button_label = "Export"
  self.cancel_button_label = "Cancel"
  self.no_confirmation = false

  # rubocop:disable Metrics/MethodLength
  def handle(query:, _fields:, _current_user:, _resource:, **)
    filename = "mailkick_opt_outs_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"

    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["ID", "Email", "User Type", "User ID", "Active", "List", "Reason", "Created At"]

      query.each do |record|
        csv << [
          record.id,
          record.email,
          record.user_type,
          record.user_id,
          record.active,
          record.list,
          record.reason,
          record.created_at&.strftime("%Y-%m-%d %H:%M:%S")
        ]
      end
    end

    download csv_data, filename

    succeed "Exported #{query.count} opt-outs"
  end
  # rubocop:enable Metrics/MethodLength
end
