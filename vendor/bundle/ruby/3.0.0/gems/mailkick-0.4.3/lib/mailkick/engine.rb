module Mailkick
  class Engine < ::Rails::Engine
    isolate_namespace Mailkick

    initializer "mailkick" do |app|
      Mailkick.discover_services unless Mailkick.services.any?

      Mailkick.secret_token ||= begin
        creds =
          if app.respond_to?(:credentials) && app.credentials.secret_key_base
            app.credentials
          elsif app.respond_to?(:secrets)
            app.secrets
          else
            app.config
          end

        creds.respond_to?(:secret_key_base) ? creds.secret_key_base : creds.secret_token
      end
    end
  end
end
