module SimpleDiscussion
  class Engine < ::Rails::Engine
    engine_name 'simple_discussion'

    # Grab the Rails default url options and use them for sending notifications
    config.after_initialize do
      SimpleDiscussion::Engine.routes.default_url_options = ActionMailer::Base.default_url_options
    end
  end
end
