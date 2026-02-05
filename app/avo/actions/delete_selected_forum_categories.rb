# frozen_string_literal: true

class Avo::Actions::DeleteSelectedForumCategories < Avo::BaseAction
  self.name = "Delete Selected Forum Categories"
  self.message = "Permanently delete selected forum categories"
  self.confirm_button_label = "Delete"
  self.cancel_button_label = "Cancel"
  self.no_confirmation = false

  def handle(**args)
    records = fetch_records(args)

    return error "No records selected to delete" if records.empty?

    destroyed = 0
    records.each do |record|
      destroyed += 1 if record.destroy
    end

    succeed "Deleted #{destroyed} forum categor#{'y' if destroyed == 1}#{'ies' unless destroyed == 1}" unless destroyed.zero?
    error "No records were deleted" if destroyed.zero?
  end

  private

    def fetch_records(args)
      query = args[:query]
      return [] if query.blank? || (query.respond_to?(:empty?) && query.empty?)
      query.respond_to?(:to_a) ? query.to_a : query
    end
end
