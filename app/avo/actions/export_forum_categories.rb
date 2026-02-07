# frozen_string_literal: true

class Avo::Actions::ExportForumCategories < Avo::BaseAction
  self.name = "Export Forum Categories"
  self.message = "Export selected forum categories to CSV"
  self.confirm_button_label = "Export"
  self.cancel_button_label = "Cancel"
  self.no_confirmation = false
  self.standalone = true

  def handle(**args)
    records = fetch_records(args)

    return error "No records to export" if records.empty?

    csv_data = generate_csv(records)
    filename = "forum_categories_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"

    download csv_data, filename
    succeed "Exported #{records.count} forum category"
  end

  private

    def fetch_records(args)
      fields = args[:fields] || {}

      if should_export_all?(fields, args[:query])
        ::ForumCategory.all.to_a
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
      ["ID", "Name", "Slug", "Color", "Created At", "Updated At"]
    end

    def csv_row(record)
      [
        record.id,
        record.name,
        record.slug,
        record.color,
        record.created_at&.strftime("%Y-%m-%d %H:%M:%S"),
        record.updated_at&.strftime("%Y-%m-%d %H:%M:%S")
      ]
    end
end
