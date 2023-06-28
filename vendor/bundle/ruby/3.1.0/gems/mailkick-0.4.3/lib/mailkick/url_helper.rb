module Mailkick
  module UrlHelper
    def mailkick_unsubscribe_url(email: nil, user: nil, list: nil, **options)
      email ||= controller.try(:message).try(:to).try(:first)

      Mailkick::Engine.routes.url_helpers.url_for(
        (ActionMailer::Base.default_url_options || {}).merge(options).merge(
          controller: "mailkick/subscriptions",
          action: "unsubscribe",
          id: Mailkick.generate_token(email, user: user, list: list)
        )
      )
    end
  end
end
