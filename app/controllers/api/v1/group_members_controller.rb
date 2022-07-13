# frozen_string_literal: true

class Api::V1::GroupMembersController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_group, only: %i[index create]
  before_action :set_group_member, only: %i[destroy update]
  before_action :check_show_access, only: %i[index]
  before_action :check_edit_access, only: %i[create]
  before_action :check_primary_mentor_access, only: %i[destroy update]

  # GET /api/v1/groups/:group_id/members/
  def index
    @group_members = paginate(@group.group_members)
    @options = { links: link_attrs(@group_members, api_v1_group_members_url(@group.id)) }
    render json: Api::V1::GroupMemberSerializer.new(@group_members, @options)
  end

  # POST /api/v1/groups/:group_id/members/
  def create
    dummy = GroupMember.new
    dummy.group_id = group_member_params[:group_id]
    authorize dummy, :primary_mentor?
    @group = Group.find(group_member_params[:group_id])
    is_mentor = false
    is_mentor = group_member_params[:mentor] == "true" if group_member_params[:mentor]

    mails_handler = MailsHandler.new(group_member_params[:emails], @group, current_user, is_mentor)
    # parse mails as valid or invalid
    mails_handler.parse
    # create invitation or group member
    mails_handler.create_invitation_or_group_member

    render json: {
      added: mails_handler.added_mails,
      pending: mails_handler.pending_mails,
      invalid: mails_handler.invalid_mails
    }
  end

  # DELETE /api/v1/group/members/:id
  def destroy
    @group_member.destroy!
    render json: {}, status: :no_content
  end

  # PATCH/PUT /api/v1/group/members/:id
  # Only used to set or revoke mentorship
  def update
    @group_member.update(group_member_update_params)
    render json: {}, status: :accepted
  end

  private

    def set_group
      @group = Group.find(params[:group_id])
    end

    def set_group_member
      @group_member = GroupMember.find(params[:id])
    end

    def check_show_access
      # checks if current_user has access to get group members
      authorize @group, :show_access?
    end

    def check_mentor_access
      # check mentor access?
      authorize @group_member, :mentor?
    end

    def check_primary_mentor_access
      # checks if current user is primary_mentor
      authorize @group_member, :primary_mentor?
    end

    def check_edit_access
      # check if current user has admin/mentor rights to create group members
      authorize @group, :admin_access?
    end

    def group_member_params
      params.require(:group_member).permit(:group_id, :user_id, :emails, :mentor)
    end

    def group_member_update_params
      params.require(:group_member).permit(:mentor)
    end
end
