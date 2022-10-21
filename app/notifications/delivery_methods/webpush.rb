# frozen_string_literal: true

class DeliveryMethods::Webpush < Noticed::DeliveryMethods::Base
  def deliver
    # Logic for sending the notification
    user = User.find(params[:user_id])
    project = Project.find(params[:project_id])
    url = "/users/#{recipient.id}/notifications"
    recipient.push_subscriptions.each do |sub|
      if params[:webpush_type] == "star"
        sub.send_push_notification("#{user.name} starred your project #{project.name}!", url)
      else
        sub.send_push_notification("#{user.name} forked your project #{project.name}!", url)
      end
    end
  end
end
