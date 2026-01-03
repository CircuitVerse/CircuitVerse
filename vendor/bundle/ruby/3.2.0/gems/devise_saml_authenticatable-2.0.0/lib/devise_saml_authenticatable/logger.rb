module DeviseSamlAuthenticatable

  class Logger    
    def self.send(message, log_level = ::Logger::INFO, logger = Rails.logger)
      if ::Devise.saml_logger
        logger.add log_level, "  \e[36msaml:\e[0m #{message}"
      end
    end
  end

end
