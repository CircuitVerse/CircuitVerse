# frozen_string_literal: true

class Api::V1::GroupMembersController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_group, only: %i[index create]
  before_action :set_group_member, only: %i[destroy]
  before_action :check_show_access, only: %i[index]
  before_action :check_edit_access, only: %i[create]
  before_action :check_mentor_access, only: %i[destroy]

  # GET /api/v1/groups/:group_id/members/
  def index
    @group_members = paginate(@group.group_members)
    @options = { links: link_attrs(@group_members, api_v1_group_members_url(@group.id)) }
    render json: Api::V1::GroupMemberSerializer.new(@group_members, @options)
  end

  # POST /api/v1/groups/:group_id/members/
  def create
    mails_handler = MailsHandler.new(params[:emails], @group, current_user)
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

    def check_edit_access
      # check if current user has admin/mentor rights to create group members
      authorize @group, :admin_access?
    end
end
