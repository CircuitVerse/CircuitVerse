# frozen_string_literal: true

class Avo::Actions::ExportGroupMembers < Avo::BaseAction
  self.name = "Export Group Members"
  self.message = "Export members data for selected groups?"
  self.confirm_button_label = "Export"
  self.cancel_button_label = "Cancel"

  def handle(query:, _fields:, _current_user:, _resource:, **_args)
    members_data = []

    query.each do |group|
      group.group_members.includes(:user).each do |member|
        members_data << {
          group_name: group.name,
          group_id: group.id,
          user_name: member.user.name,
          user_email: member.user.email,
          mentor: member.mentor,
          joined_at: member.created_at
        }
      end
    end

    csv_data = CSV.generate(headers: true) do |csv|
      csv << members_data.first.keys if members_data.any?
      members_data.each do |member_data|
        csv << member_data.values
      end
    end

    download csv_data, "group_members_export_#{Time.zone.now.to_i}.csv"
  end
end
