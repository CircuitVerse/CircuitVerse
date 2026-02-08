# frozen_string_literal: true

class Avo::Actions::Users::DeleteSelected < Avo::BaseAction
  self.name = "Delete Selected"
  self.message = "Are you sure you want to permanently delete the selected users?"
  self.confirm_button_label = "Delete"
  self.cancel_button_label = "Cancel"

  def handle(**args)
    records = fetch_records(args)

    return error "No users selected to delete" if records.empty?

    destroyed = 0
    records.each do |record|
      destroyed += 1 if record.destroy
    end

    if destroyed.zero?
      error "No users were deleted"
    else
      succeed "Deleted #{destroyed} #{'user'.pluralize(destroyed)}"
    end
  end

  private

    def fetch_records(args)
      query = args[:query]
      return [] if query.blank? || (query.respond_to?(:empty?) && query.empty?)

      query.respond_to?(:to_a) ? query.to_a : query
    end
end
