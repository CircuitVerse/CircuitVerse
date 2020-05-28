# frozen_string_literal: true

class Api::V1::GroupMembersController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_group, only: %i[index create]
  before_action :check_edit_access, only: %i[create]

  # GET /api/v1/groups/:group_id/group_members/
  def index
    # checks if current_user has access to get group members
    authorize @group, :show_access?

    @group_members = paginate(@group.group_members)
    @options = { links: link_attrs(@group_members, api_v1_group_group_members_url(@group.id)) }
    render json: Api::V1::GroupMemberSerializer.new(@group_members, @options)
  end

  # POST /api/v1/groups/:group_id/group_members/
  def create
    parse_mails(params[:emails])
    newly_added = @valid_mails - @existing_mails

    @pending_mails = []
    @added_mails = []

    newly_added.each do |email|
      user = User.find_by(email: email)
      if user.nil?
        @pending_mails.push(email)
        PendingInvitation.where(group_id: @group.id, email: email).first_or_create
      else
        @added_mails.push(email)
        GroupMember.where(group_id: @group.id, user_id: user.id).first_or_create
      end
    end

    render json: { added: @added_mails, pending: @pending_mails, invalid: @invalid_mails }
  end

  # DELETE /api/v1/group_members/:id
  def destroy
    @group_member = GroupMember.find(params[:id])

    # check mentor access?
    authorize @group_member, :mentor?

    @group_member.destroy!
    render json: {}, status: :no_content
  end

  private

    def set_group
      @group = Group.find(params[:group_id])
    end

    def check_edit_access
      # check if current user has admin/mentor rights to create group members
      authorize @group, :admin_access?
    end

    def parse_mails(mails)
      @valid_mails = []
      @invalid_mails = []

      mails.split(",").each do |email|
        email = email.strip
        if email.present? && Devise.email_regexp.match?(email)
          @valid_mails.push(email.downcase)
        else
          @invalid_mails.push(email)
        end
      end

      @existing_mails = User.where(
        id: @group.group_members.pluck(:user_id)
      ).pluck(:email)
    end
end
