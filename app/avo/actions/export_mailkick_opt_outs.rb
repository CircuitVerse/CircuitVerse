# frozen_string_literal: true

class Avo::Actions::ExportMailkickOptOuts < Avo::BaseAction
  self.name = "Export Opt-Outs"
  self.message = "Export selected opt-outs to CSV"
  self.confirm_button_label = "Export"
  self.cancel_button_label = "Cancel"
  self.no_confirmation = false
  self.standalone = true

  def handle(**args)
    records = fetch_records(args)

    return error "No records to export" if records.empty?

    csv_data = generate_csv(records)
    filename = "mailkick_opt_outs_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"

    download csv_data, filename
    succeed "Exported #{records.count} opt-out#{'s' unless records.one?}"
  end
  # rubocop:enable Metrics/AbcSize

  private

    def fetch_records(args)
      fields = args[:fields] || {}

      if should_export_all?(fields, args[:query])
        ::Mailkick::OptOut.all.to_a
      else
        extract_query_records(args[:query])
      end
    end

    def should_export_all?(fields, query)
      fields[:avo_selected_all] == "true" || query.blank? || query.empty?
    end

    def extract_query_records(query)
      query.respond_to?(:to_a) ? query.to_a : query
    end

    def generate_csv(records)
      CSV.generate(headers: true) do |csv|
        csv << csv_headers
        records.each { |record| csv << csv_row(record) }
      end
    end

    def csv_headers
      ["ID", "Email", "User Type", "User ID", "User Name", "Active", "List", "Reason", "Created At", "Updated At"]
    end

    def csv_row(record)
      [
        record.id,
        record.email,
        record.user_type,
        record.user_id,
        record.user&.name || record.user&.email || "N/A",
        record.active,
        record.list,
        record.reason,
        record.created_at&.strftime("%Y-%m-%d %H:%M:%S"),
        record.updated_at&.strftime("%Y-%m-%d %H:%M:%S")
      ]
    end
end
