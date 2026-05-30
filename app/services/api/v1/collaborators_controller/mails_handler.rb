# frozen_string_literal: true

class Api::V1::CollaboratorsController
  class MailsHandler
    # @return [Array<String>]
    attr_reader :valid_mails
    # @return [Array<String>]
    attr_reader :invalid_mails
    # @return [Array<String>]
    attr_reader :existing_mails

    # initialize the class with mails, project and current_user to be used in class
    # @param [String] mails
    # @param [Project] project
    # @param [User] current_user
    def initialize(mails, project, current_user)
      @mails = mails
      @project = project
      @current_user = current_user
      # initialize empty valid and invalid mails
      @valid_mails = []
      @invalid_mails = []
    end

    # parse emails as valid, invalid or existing mails
    # @return [void]
    def parse
      @mails.split(",").each do |email|
        email = email.strip
        if email.present? && email != @current_user.email && Devise.email_regexp.match?(email)
          @valid_mails.push(email)
        else
          @invalid_mails.push(email)
        end
      end

      @existing_mails = User.where(
        id: @project.collaborations.pluck(:user_id)
      ).pluck(:email)
    end

    # returns added mails
    # @return [Array<String>]
    def added_mails
      newly_added = valid_mails - existing_mails
      added_mails = []
      # checks if user exists and adds to added_mails
      newly_added.each do |email|
        user = User.find_by(email: email)
        if user.present?
          added_mails.push(email)
          Collaboration.where(project_id: @project.id, user_id: user.id).first_or_create
        end
      end
      # returns added_mails
      added_mails
    end
  end
end
