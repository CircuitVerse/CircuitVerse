# frozen_string_literal: true

class Avo::Actions::ExportGroupMembers < Avo::BaseAction
  self.name = "Export Group Members"
  self.message = "Export members data for selected groups?"
  self.confirm_button_label = "Export"
  self.cancel_button_label = "Cancel"

  def handle(query:, _fields:, _current_user:, _resource:, **_args)
    members_data = collect_members_data(query)
    csv_data = generate_csv(members_data)
    download csv_data, "group_members_export_#{Time.zone.now.to_i}.csv"
  end

  private

    def collect_members_data(query)
      [].tap do |data|
        query.each do |group|
          group.group_members.includes(:user).find_each do |member|
            data << {
              group_name: group.name,
              group_id: group.id,
              user_name: member.user.name,
              user_email: member.user.email,
              mentor: member.mentor,
              joined_at: member.created_at
            }
          end
        end
      end
    end

    def generate_csv(data)
      CSV.generate(headers: true) do |csv|
        csv << data.first.keys if data.any?
        data.each { |row| csv << row.values }
      end
    end
end
