module Commontator
  module SharedHelper
    def commontator_thread(commontable)
      user = Commontator.current_user_proc.call(self)
      thread = commontable.thread
      
      render(partial: 'commontator/shared/thread',
             locals: { thread: thread,
                          user: user }).html_safe
    end

    def commontator_gravatar_image_tag(user, border = 1, options = {})
      email = Commontator.commontator_email(user) || ''
      name = Commontator.commontator_name(user) || ''

      base = request.ssl? ? "s://secure" : "://www"
      hash = Digest::MD5.hexdigest(email)
      url = "http#{base}.gravatar.com/avatar/#{hash}?#{options.to_query}"
      
      image_tag(url, { alt: name,
                       title: name,
                       border: border })
    end
  end
end
