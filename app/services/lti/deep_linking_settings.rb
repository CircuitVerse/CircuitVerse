# frozen_string_literal: true

module Lti
  class DeepLinkingSettings
    MESSAGE_TYPE = "LtiDeepLinkingRequest"
    MESSAGE_TYPE_CLAIM = "https://purl.imsglobal.org/spec/lti/claim/message_type"
    SETTINGS_CLAIM = "https://purl.imsglobal.org/spec/lti-dl/claim/deep_linking_settings"
    PURPOSE = "lti.deep_linking.settings"
    TTL = 30.minutes

    class Error < StandardError; end

    attr_reader :return_url, :accept_types, :document_targets, :data

    class << self
      def requested?(payload)
        payload[MESSAGE_TYPE_CLAIM] == MESSAGE_TYPE
      end

      def from_claim(payload)
        new(payload[SETTINGS_CLAIM])
      end

      # The picker returns on a separate request, so the settings travel signed
      # rather than in a session a cross-site POST would not carry.
      def restore(stashed)
        settings = verifier.verified(stashed.to_s, purpose: PURPOSE)
        raise Error, "invalid or expired deep linking settings" if settings.blank?

        new(settings)
      end

      def verifier
        Rails.application.message_verifier(PURPOSE)
      end
    end

    def initialize(settings)
      settings = settings.to_h.stringify_keys
      @return_url = settings["deep_link_return_url"]
      raise Error, "missing deep_link_return_url" if @return_url.blank?

      @accept_types = Array(settings["accept_types"])
      @document_targets = Array(settings["accept_presentation_document_targets"])
      @accept_multiple = settings["accept_multiple"] || false
      @data = settings["data"]
    end

    def accept_multiple?
      @accept_multiple
    end

    def stash
      self.class.verifier.generate(to_h, purpose: PURPOSE, expires_in: TTL)
    end

    def to_h
      { "deep_link_return_url" => return_url, "accept_types" => accept_types,
        "accept_presentation_document_targets" => document_targets,
        "accept_multiple" => @accept_multiple, "data" => data }
    end
  end
end
