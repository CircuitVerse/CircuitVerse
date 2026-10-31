# frozen_string_literal: true

module Autograder
  class AgsPush
    def self.call(project:, score:)
      assignment = project.assignment
      link = assignment&.lti_resource_link
      sub = project.author&.lti_sub
      return unless link&.lineitem_url.present? && sub.present?

      token = Lti::AccessToken.fetch(link.lti_deployment, [Lti::Score::SCOPE], signing_key: Lti::KeyManager.private_key)
      given = score.round.clamp(0, 100)
      Lti::Score.publish(link.lineitem_url, token, user_id: sub, score_given: given, score_maximum: 100)
    rescue Lti::AccessToken::Error, Lti::Score::Error
      nil
    end
  end
end
