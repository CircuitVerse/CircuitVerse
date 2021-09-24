module IMS::LTI
  # Class used to represent an LTI configuration
  #
  # It can create and read the Common Cartridge XML representation of LTI links
  # as described here: http://www.imsglobal.org/LTI/v1p1pd/ltiIMGv1p1pd.html#_Toc309649689
  #
  # == Usage
  # To generate an XML configuration:
  #
  #    # Create a config object and set some options
  #    tc = IMS::LTI::ToolConfig.new(:title => "Example Sinatra Tool Provider", :launch_url => url)
  #    tc.description = "This example LTI Tool Provider supports LIS Outcome pass-back."
  #
  #    # generate the XML
  #    tc.to_xml
  #
  # Or to create a config object from an XML String:
  #
  #    tc = IMS::LTI::ToolConfig.create_from_xml(xml)
  class ToolConfig
    attr_reader :custom_params, :extensions

    attr_accessor :title, :description, :launch_url, :secure_launch_url,
                  :icon, :secure_icon, :cartridge_bundle, :cartridge_icon,
                  :vendor_code, :vendor_name, :vendor_description, :vendor_url,
                  :vendor_contact_email, :vendor_contact_name

    # Create a new ToolConfig with the given options
    #
    # @param opts [Hash] The initial options for the ToolConfig
    def initialize(opts={})
      @custom_params = opts.delete("custom_params") || {}
      @extensions = opts.delete("extensions") || {}

      opts.each_pair do |key, val|
        self.send("#{key}=", val) if self.respond_to?("#{key}=")
      end
    end

    # Create a ToolConfig from the given XML
    #
    # @param xml [String]
    def self.create_from_xml(xml)
      tc = ToolConfig.new
      tc.process_xml(xml)

      tc
    end

    def set_custom_param(key, val)
      @custom_params[key] = val
    end

    def get_custom_param(key)
      @custom_params[key]
    end

    # Set the extension parameters for a specific vendor
    #
    # @param ext_key [String] The identifier for the vendor-specific parameters
    # @param ext_params [Hash] The parameters, this is allowed to be two-levels deep
    def set_ext_params(ext_key, ext_params)
      raise ArgumentError unless ext_params.is_a?(Hash)
      @extensions[ext_key] = ext_params
    end

    def get_ext_params(ext_key)
      @extensions[ext_key]
    end

    def set_ext_param(ext_key, param_key, val)
      @extensions[ext_key] ||= {}
      @extensions[ext_key][param_key] = val
    end

    def get_ext_param(ext_key, param_key)
      @extensions[ext_key] && @extensions[ext_key][param_key]
    end

    # Namespaces used for parsing configuration XML
    LTI_NAMESPACES = {
            "xmlns" => 'http://www.imsglobal.org/xsd/imslticc_v1p0',
            "blti" => 'http://www.imsglobal.org/xsd/imsbasiclti_v1p0',
            "lticm" => 'http://www.imsglobal.org/xsd/imslticm_v1p0',
            "lticp" => 'http://www.imsglobal.org/xsd/imslticp_v1p0',
    }

    # Parse tool configuration data out of the Common Cartridge LTI link XML
    def process_xml(xml)
      doc = REXML::Document.new xml
      if root = REXML::XPath.first(doc, 'xmlns:cartridge_basiclti_link')
        @title = get_node_text(root, 'blti:title')
        @description = get_node_text(root, 'blti:description')
        @launch_url = get_node_text(root, 'blti:launch_url')
        @secure_launch_url = get_node_text(root, 'blti:secure_launch_url')
        @icon = get_node_text(root, 'blti:icon')
        @secure_icon = get_node_text(root, 'blti:secure_icon')
        @cartridge_bundle = get_node_att(root, 'xmlns:cartridge_bundle', 'identifierref')
        @cartridge_icon = get_node_att(root, 'xmlns:cartridge_icon', 'identifierref')

        if vendor = REXML::XPath.first(root, 'blti:vendor')
          @vendor_code = get_node_text(vendor, 'lticp:code')
          @vendor_description = get_node_text(vendor, 'lticp:description')
          @vendor_name = get_node_text(vendor, 'lticp:name')
          @vendor_url = get_node_text(vendor, 'lticp:url')
          @vendor_contact_email = get_node_text(vendor, '//lticp:contact/lticp:email')
          @vendor_contact_name = get_node_text(vendor, '//lticp:contact/lticp:name')
        end

        if custom = REXML::XPath.first(root, 'blti:custom', LTI_NAMESPACES)
          set_properties(@custom_params, custom)
        end

        REXML::XPath.each(root, 'blti:extensions', LTI_NAMESPACES) do |vendor_ext_node|
          platform = vendor_ext_node.attributes['platform']
          properties = {}
          set_properties(properties, vendor_ext_node)
          set_options(properties, vendor_ext_node)
          self.set_ext_params(platform, properties)
        end

      end
    end

    # Generate XML from the current settings
    def to_xml(opts = {})
      raise IMS::LTI::InvalidLTIConfigError, "A launch url is required for an LTI configuration." unless self.launch_url || self.secure_launch_url

      builder = Builder::XmlMarkup.new(:indent => opts[:indent] || 0)
      builder.instruct!
      builder.cartridge_basiclti_link("xmlns" => "http://www.imsglobal.org/xsd/imslticc_v1p0",
                                      "xmlns:blti" => 'http://www.imsglobal.org/xsd/imsbasiclti_v1p0',
                                      "xmlns:lticm" => 'http://www.imsglobal.org/xsd/imslticm_v1p0',
                                      "xmlns:lticp" => 'http://www.imsglobal.org/xsd/imslticp_v1p0',
                                      "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
                                      "xsi:schemaLocation" => "http://www.imsglobal.org/xsd/imslticc_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticc_v1p0.xsd http://www.imsglobal.org/xsd/imsbasiclti_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imsbasiclti_v1p0p1.xsd http://www.imsglobal.org/xsd/imslticm_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticm_v1p0.xsd http://www.imsglobal.org/xsd/imslticp_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticp_v1p0.xsd"
      ) do |blti_node|

        %w{title description launch_url secure_launch_url icon secure_icon}.each do |key|
          blti_node.blti key.to_sym, self.send(key) if self.send(key)
        end

        vendor_keys = %w{name code description url}
        if vendor_keys.any?{|k|self.send("vendor_#{k}")} || vendor_contact_email
          blti_node.blti :vendor do |v_node|
            vendor_keys.each do |key|
              v_node.lticp key.to_sym, self.send("vendor_#{key}") if self.send("vendor_#{key}")
            end
            if vendor_contact_email
              v_node.lticp :contact do |c_node|
                c_node.lticp :name, vendor_contact_name
                c_node.lticp :email, vendor_contact_email
              end
            end
          end
        end

        if !@custom_params.empty?
          blti_node.tag!("blti:custom") do |custom_node|
            @custom_params.keys.sort.each do |key|
              val = @custom_params[key]
              custom_node.lticm :property, val, 'name' => key
            end
          end
        end

        if !@extensions.empty?
          @extensions.keys.sort.each do |ext_platform|
            ext_params = @extensions[ext_platform]
            blti_node.blti(:extensions, :platform => ext_platform) do |ext_node|
              ext_params.keys.sort.each do |key|
                nest_xml(ext_node, key, ext_params[key])
              end
            end
          end
        end

        blti_node.cartridge_bundle(:identifierref => @cartridge_bundle) if @cartridge_bundle
        blti_node.cartridge_icon(:identifierref => @cartridge_icon) if @cartridge_icon

      end
    end

    private

    def nest_xml(ext_node, key, value)
      if value.is_a?(Hash)
        ext_node.lticm(:options, :name => key) do |type_node|
          value.keys.sort.each do |sub_key|
            nest_xml(type_node, sub_key, value[sub_key])
          end
        end
      else
        ext_node.lticm :property, value, 'name' => key
      end
    end

    def get_node_text(node, path)
      if val = REXML::XPath.first(node, path, LTI_NAMESPACES)
        val.text
      else
        nil
      end
    end

    def get_node_att(node, path, att)
      if val = REXML::XPath.first(node, path, LTI_NAMESPACES)
        val.attributes[att]
      else
        nil
      end
    end

    def set_properties(hash, node)
      REXML::XPath.each(node, 'lticm:property', LTI_NAMESPACES) do |prop|
        hash[prop.attributes['name']] = prop.text
      end
    end

    def set_options(hash, node)
      REXML::XPath.each(node, 'lticm:options', LTI_NAMESPACES) do |options_node|
        opt_name = options_node.attributes['name']
        options = {}
        set_properties(options, options_node)
        set_options(options, options_node)
        hash[opt_name] = options
      end
    end

  end
end
