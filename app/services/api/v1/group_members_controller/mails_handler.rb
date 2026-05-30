# frozen_string_literal: true

class Api::V1::GroupMembersController
  class MailsHandler
    # @return [Array<String>]
    attr_reader :added_mails
    # @return [Array<String>]
    attr_reader :invalid_mails
    # @return [Array<String>]
    attr_reader :pending_mails

    # initialize the class with mails, group and current_user to be used in class
    # @param [String] mails
    # @param [Group] group
    # @param [User] current_user
    def initialize(mails, group, current_user)
      @mails = mails
      @group = group
      @current_user = current_user
      # initialize empty valid, invalid, pending & added mails
      @valid_mails = []
      @invalid_mails = []
      @pending_mails = []
      @added_mails = []
    end

    # parse emails as valid, invalid or existing mails
    # @return [void]
    def parse
      @mails.split(",").each do |email|
        email = email.strip
        if email.present? && Devise.email_regexp.match?(email)
          @valid_mails.push(email)
        else
          @invalid_mails.push(email)
        end
      end

      @existing_mails = User.where(
        id: @group.group_members.pluck(:user_id)
      ).pluck(:email)
    end

    # Create invitation or group_member for valid mails
    # @return [void]
    def create_invitation_or_group_member
      newly_added = @valid_mails - @existing_mails

      # checks for every newly added mail if the user exists or not
      newly_added.each do |email|
        user = User.find_by(email: email)
        if user.nil?
          # invitation being sent to non-existent user
          @pending_mails.push(email)
          PendingInvitation.where(group_id: @group.id, email: email).first_or_create
        else
          # create group_member for existent users
          @added_mails.push(email)
          GroupMember.where(group_id: @group.id, user_id: user.id).first_or_create
        end
      end
    end
  end
end
