# frozen_string_literal: true

class PreviousNotification < Noticed::Base
  deliver_by :database, association: :noticed_notifications
  # deliver_by :email, mailer: "UserMailer"
  # deliver_by :slack
  # deliver_by :custom, class: "MyDeliveryMethod"

  # Add required params
  #
  # param :post

  # Define helper methods to make rendering easier.
  #
  def message
    user = User.find(params[:user_id])
    "#{user.name} #{params[:message]}"
  end

  def icon
    if params[:type] == "Star"
      "far fa-star fa-thin"
    else
      "fas fa-code-branch"
    end
  end

  def url
    params[:path]
  end
end
