require 'ruby-saml'
module DeviseSamlAuthenticatable
  module SamlConfig
    def saml_config(idp_entity_id = nil, request = nil)
      return file_based_config if file_based_config
      return adapter_based_config(idp_entity_id, request) if Devise.idp_settings_adapter

      Devise.saml_config
    end

    private

    def file_based_config
      return @file_based_config if @file_based_config
      idp_config_path = "#{Rails.root}/config/idp.yml"

      if File.exist?(idp_config_path)
        @file_based_config ||= OneLogin::RubySaml::Settings.new(YAML.load(File.read(idp_config_path))[Rails.env])
      end
    end

    def adapter_based_config(idp_entity_id, request)
      config = Marshal.load(Marshal.dump(Devise.saml_config))

      if idp_settings_adapter.method(:settings).parameters.length == 1
        settings = idp_settings_adapter.settings(idp_entity_id)
      else
        settings = idp_settings_adapter.settings(idp_entity_id, request)
      end

      settings.each do |k,v|
        acc = "#{k.to_s}=".to_sym

        if config.respond_to? acc
          config.send(acc, v)
        end
      end
      config
    end

    def get_idp_entity_id(params)
      idp_entity_id_reader.entity_id(params)
    end

    def idp_entity_id_reader
      if Devise.idp_entity_id_reader.respond_to?(:entity_id)
        Devise.idp_entity_id_reader
      else
        @idp_entity_id_reader ||= Devise.idp_entity_id_reader.constantize
      end
    end

    def idp_settings_adapter
      if Devise.idp_settings_adapter.respond_to?(:settings)
        Devise.idp_settings_adapter
      else
        @idp_settings_adapter ||= Devise.idp_settings_adapter.constantize
      end
    end
  end
end
