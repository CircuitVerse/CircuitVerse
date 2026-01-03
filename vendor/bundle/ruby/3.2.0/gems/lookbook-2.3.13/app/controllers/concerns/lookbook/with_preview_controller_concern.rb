module Lookbook
  module WithPreviewControllerConcern
    extend ActiveSupport::Concern

    def preview_controller
      @_preview_controller ||= begin
        # In order to get URL helpers working correctly in the preview,
        # the request needs to look like it's coming from the host app,
        # not the Lookbook engine. So we try to get the controller and action
        # for the root path and use that as the 'fake' request context instead.
        path_parameters = begin
          request_path = main_app.respond_to?(:root_path) ? main_app.root_path : "/"
          Rails.application.routes.recognize_path(request_path)
        rescue
          # Fix for authenticated devise paths
          if main_app.respond_to?(:new_user_session_path)
            Rails.application.routes.recognize_path(main_app.new_user_session_path)
          end
        end

        preview_request = request.clone
        preview_request.path_parameters = path_parameters if path_parameters.present?

        controller = Engine.preview_controller.new
        controller.request = preview_request
        controller.response = response

        controller
      end
    end
  end
end
