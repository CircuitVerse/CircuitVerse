module IMS::LTI
  # Mixin module for managing LTI Launch Data
  #
  # Launch data documentation:
  # http://www.imsglobal.org/lti/v1p1pd/ltiIMGv1p1pd.html#_Toc309649684
  module LaunchParams

    # List of the standard launch parameters for an LTI launch
    LAUNCH_DATA_PARAMETERS = %w{
      accept_media_types
      accept_multiple
      accept_presentation_document_targets
      accept_unsigned
      auto_create
      content_item_return_url
      context_id
      context_label
      context_title
      context_type
      launch_presentation_css_url
      launch_presentation_document_target
      launch_presentation_height
      launch_presentation_locale
      launch_presentation_return_url
      launch_presentation_width
      lis_course_offering_sourcedid
      lis_course_section_sourcedid
      lis_outcome_service_url
      lis_person_contact_email_primary
      lis_person_name_family
      lis_person_name_full
      lis_person_name_given
      lis_person_sourcedid
      lis_result_sourcedid
      lti_message_type
      lti_version
      oauth_callback
      oauth_consumer_key
      oauth_nonce
      oauth_signature
      oauth_signature_method
      oauth_timestamp
      oauth_version
      resource_link_description
      resource_link_id
      resource_link_title
      roles
      role_scope_mentor
      tool_consumer_info_product_family_code
      tool_consumer_info_version
      tool_consumer_instance_contact_email
      tool_consumer_instance_description
      tool_consumer_instance_guid
      tool_consumer_instance_name
      tool_consumer_instance_url
      user_id
      user_image
    }

    LAUNCH_DATA_PARAMETERS.each { |p| attr_accessor p }

    # Hash of custom parameters, the keys will be prepended with "custom_" at launch
    attr_accessor :custom_params

    # Hash of extension parameters, the keys will be prepended with "ext_" at launch
    attr_accessor :ext_params

    # Hash of parameters to add to the launch. These keys will not be prepended
    # with any value at launch
    attr_accessor :non_spec_params

    # Set the roles for the current launch
    #
    # Full list of roles can be found here:
    # http://www.imsglobal.org/LTI/v1p1pd/ltiIMGv1p1pd.html#_Toc309649700
    #
    # LIS roles include:
    # * Student
    # * Faculty
    # * Member
    # * Learner
    # * Instructor
    # * Mentor
    # * Staff
    # * Alumni
    # * ProspectiveStudent
    # * Guest
    # * Other
    # * Administrator
    # * Observer
    # * None
    #
    # @param roles_list [String,Array] An Array or comma-separated String of roles
    def roles=(roles_list)
      if roles_list
        if roles_list.is_a?(Array)
          @roles = roles_list
        else
          @roles = roles_list.split(",")
        end
      else
        @roles = nil
      end
    end

    def set_custom_param(key, val)
      @custom_params[key] = val
    end

    def get_custom_param(key)
      @custom_params[key]
    end

    def set_non_spec_param(key, val)
      @non_spec_params[key] = val
    end

    def get_non_spec_param(key)
      @non_spec_params[key]
    end

    def set_ext_param(key, val)
      @ext_params[key] = val
    end

    def get_ext_param(key)
      @ext_params[key]
    end

    # Create a new Hash with all launch data. Custom/Extension keys will have the
    # appropriate value prepended to the keys and the roles are set as a comma
    # separated String
    def to_params
      params = launch_data_hash.merge(add_key_prefix(@custom_params, 'custom')).merge(add_key_prefix(@ext_params, 'ext')).merge(@non_spec_params)
      params["roles"] = @roles.join(",") if @roles
      params
    end

    # Populates the launch data from a Hash
    #
    # Only keys in LAUNCH_DATA_PARAMETERS and that start with 'custom_' or 'ext_'
    # will be pulled from the provided Hash
    def process_params(params)
      params.each_pair do |key, val|
        if LAUNCH_DATA_PARAMETERS.member?(key)
          self.send("#{key}=", val)
        elsif key =~ /\Acustom_(.+)\Z/
          @custom_params[$1] = val
        elsif key =~ /\Aext_(.+)\Z/
          @ext_params[$1] = val
        end
      end
    end

    private

    def launch_data_hash
      LAUNCH_DATA_PARAMETERS.inject({}) { |h, k| h[k] = self.send(k) if self.send(k); h }
    end

    def add_key_prefix(hash, prefix)
      hash.keys.inject({}) { |h, k| h["#{prefix}_#{k}"] = hash[k]; h }
    end

  end
end
