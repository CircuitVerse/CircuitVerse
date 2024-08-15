module IMS::LTI
  module Extensions
    # Module that adds Canvas specific LTI extensions
    #
    # It adds convenience methods for generating common canvas use case LTI configurations
    #
    # == Usage
    # To generate an XML configuration:
    #
    #    # Create a config object and set some options
    #    tc = IMS::LTI::ToolConfig.new(:title => "Example Sinatra Tool Provider", :launch_url => url)
    #    tc.description = "This example LTI Tool Provider supports LIS Outcome pass-back."
    #
    #    # Extend the Canvas Tool config and add canvas related extensions
    #    tc.extend IMS::LTI::Extensions::Canvas::ToolConfig
    #    tc.homework_submission! 'http://someplace.com/homework', 'Find Homework'
    #
    #    # generate the XML
    #    tc.to_xml
    #
    # Or to create a config object from an XML String:
    #
    #    tc = IMS::LTI::ToolConfig.create_from_xml(xml)

    module Canvas
      module ToolConfig
        PLATFORM = 'canvas.instructure.com'

        # Canvas extension defaults
        # These properties will cascade down to any options that are configured
        def set_canvas_ext_param(key, value)
          set_ext_param(PLATFORM, key, value)
        end

        def get_canvas_param(param_key)
          get_ext_param PLATFORM, param_key
        end

        def canvas_privacy_public!()
          set_canvas_ext_param(:privacy_level, 'public')
        end

        def canvas_privacy_name_only!()
          set_canvas_ext_param(:privacy_level, 'name_only')
        end

        def canvas_privacy_anonymous!()
          set_canvas_ext_param(:privacy_level, 'anonymous')
        end

        def canvas_domain!(domain)
          set_canvas_ext_param(:domain, domain)
        end

        def canvas_text!(text)
          set_canvas_ext_param(:text, text)
        end

        def canvas_icon_url!(icon_url)
          set_canvas_ext_param(:icon_url, icon_url)
        end

        def canvas_tool_id!(tool_id)
          set_canvas_ext_param(:tool_id, tool_id)
        end

        def canvas_selector_dimensions!(width, height)
          set_canvas_ext_param(:selection_width, width)
          set_canvas_ext_param(:selection_height, height)
        end

        # Canvas options
        # These configure canvas to expose the tool in various locations.  Any properties that are set
        # at this level will override the defaults for this launch of the tool

        # Enables homework submissions via the tool
        # Valid properties are url, text, selection_width, selection_height, enabled
        def canvas_homework_submission!(params = {})
          set_canvas_ext_param(:homework_submission, params)
        end

        # Adds the tool to canvas' rich text editor
        # Valid properties are url, icon_url, text, selection_width, selection_height, enabled
        def canvas_editor_button!(params = {})
          set_canvas_ext_param(:editor_button, params)
        end

        # Adds the tool to canvas' resource selector
        # Valid properties are url, text, selection_width, selection_height, enabled
        def canvas_resource_selection!(params = {})
          set_canvas_ext_param(:resource_selection, params)
        end

        # Adds the tool to account level navigation in canvas
        # Valid properties are url, text, enabled
        def canvas_account_navigation!(params = {})
          set_canvas_ext_param(:account_navigation, params)
        end

        # Adds the tool to course level navigation in canvas
        # Valid properties are url, text, visibility, default, enabled
        # Visibility describes who will see the navigation element.  Possible values are "admins", "members", and nil
        # Default determines if it is on or off by default.  Possible values are "admins", "members", and nil
        def canvas_course_navigation!(params = {})
          set_canvas_ext_param(:course_navigation, params)
        end

        # Adds the tool to user level navigation in canvas
        # Valid properties are url, text, enabled
        def canvas_user_navigation!(params = {})
          set_canvas_ext_param(:user_navigation, params)
        end

        # Adds canvas environment configurations options
        # Valid properties are launch_url, domain, test_launch_url, test_domain, beta_launch_url, beta_domain
        def canvas_environments!(params = {})
          set_canvas_ext_param(:environments, params)
        end
      end
    end
  end
end