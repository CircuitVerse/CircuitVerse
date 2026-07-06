# frozen_string_literal: true

class Api::V1::SubgroupsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_parent_group, only: %i[index create]
  before_action :set_subgroup, only: %i[show destroy update_members]
  before_action :check_show_access, only: %i[index show]
  before_action :check_manage_access, only: %i[create destroy update_members]
  before_action :set_options, only: %i[index show create]

  # GET /api/v1/groups/:group_id/subgroups
  def index
    @subgroups = paginate(@parent_group.subgroups)
    @options[:links] = link_attrs(@subgroups, api_v1_group_subgroups_url(@parent_group.id))
    render json: Api::V1::GroupSerializer.new(@subgroups, @options)
  end

  # GET /api/v1/subgroups/:id
  def show
    render json: Api::V1::GroupSerializer.new(@subgroup, @options)
  end

  # POST /api/v1/groups/:group_id/subgroups
  def create
    @subgroup = @parent_group.subgroups.new(subgroup_params)
    if @subgroup.save
      render json: Api::V1::GroupSerializer.new(@subgroup, @options), status: :created
    else
      invalid_resource!(@subgroup.errors)
    end
  end

  # DELETE /api/v1/subgroups/:id
  def destroy
    @subgroup.destroy!
    head :no_content
  end

  # PATCH /api/v1/subgroups/:id/members
  # Syncs the subgroup's (non-mentor) membership to the submitted user ids,
  # restricted to members of the parent group.
  def update_members
    parent = @subgroup.parent_group
    target_ids = Array(params[:user_ids]).map(&:to_i) & parent.group_members.pluck(:user_id)

    current_member_ids = @subgroup.group_members.member.pluck(:user_id)
    existing_ids = @subgroup.group_members.pluck(:user_id)

    @subgroup.group_members.member.where(user_id: current_member_ids - target_ids).destroy_all
    (target_ids - existing_ids).each { |user_id| @subgroup.group_members.create(user_id: user_id) }

    @options = { include: [:group_members] }
    render json: Api::V1::GroupSerializer.new(@subgroup.reload, @options), status: :accepted
  end

  private

    def set_parent_group
      @parent_group = Group.find(params.expect(:group_id))
    end

    def set_subgroup
      @subgroup = Group.where.not(parent_group_id: nil).find(params.expect(:id))
    end

    def check_show_access
      authorize(@subgroup || @parent_group, :show_access?)
    end

    # Subgroups are managed from their top-level parent by its mentors.
    def check_manage_access
      parent = @parent_group || @subgroup.parent_group
      authorize parent, :manage_subgroups?
    end

    def set_options
      @options = {}
      @options[:params] = { current_user: current_user }
    end

    def subgroup_params
      params.expect(subgroup: %i[name])
    end
end
