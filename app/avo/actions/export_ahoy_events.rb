# frozen_string_literal: true

class Avo::Actions::ExportAhoyEvents < Avo::BaseAction
  self.name = "Export Events"
  self.message = "Export selected events to CSV"
  self.confirm_button_label = "Export"
  self.cancel_button_label = "Cancel"
  self.no_confirmation = false
  self.standalone = true

  def handle(**args)
    records = fetch_records(args)

    return error "No records to export" if records.empty?

    csv_data = generate_csv(records)
    filename = "ahoy_events_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"

    download csv_data, filename
    succeed "Exported #{records.count} event#{'s' unless records.one?}"
  end

  private

    def fetch_records(args)
      fields = args[:fields] || {}

      if should_export_all?(fields, args[:query])
        ::Ahoy::Event.all.to_a
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
        csv << ["ID", "Name", "Visit ID", "User ID", "User Email", "Time", "Properties"]
        records.each { |record| csv << csv_row(record) }
      end
    end

    def csv_row(record)
      [
        record.id,
        record.name,
        record.visit_id,
        record.user_id,
        record.user&.email || "N/A",
        record.time&.strftime("%Y-%m-%d %H:%M:%S"),
        record.properties&.to_json
      ]
    end
end
