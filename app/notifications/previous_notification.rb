# To deliver this notification:
#
# PreviousNotification.with(post: @post).deliver_later(current_user)
# PreviousNotification.with(post: @post).deliver(current_user)

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
    "Hello"
  end

  def icon
    "far fa-star fa-thin"
  end

  def URL
    root_path
  end
end
