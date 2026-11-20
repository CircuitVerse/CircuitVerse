# frozen_string_literal: true

class Api::V1::SubgroupsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_parent_group, only: %i[index create]
  before_action :set_subgroup, only: %i[show destroy update_members]
  before_action :set_options

  def index
    authorize @parent_group, :show_access?
    @subgroups = paginate(@parent_group.subgroups)
    @options[:links] = link_attrs(@subgroups, api_v1_group_subgroups_url(@parent_group.id))
    render json: Api::V1::GroupSerializer.new(@subgroups, @options)
  end

  def show
    authorize @subgroup, :show_access?
    render json: Api::V1::GroupSerializer.new(@subgroup, @options)
  end

  def create
    authorize @parent_group, :manage_subgroups?
    @subgroup = @parent_group.subgroups.new(subgroup_params)
    if @subgroup.save
      render json: Api::V1::GroupSerializer.new(@subgroup, @options), status: :created
    else
      invalid_resource!(@subgroup.errors)
    end
  end

  def destroy
    authorize @subgroup.parent_group, :manage_subgroups?
    @subgroup.destroy!
    head :no_content
  end

  def update_members
    authorize @subgroup.parent_group, :manage_subgroups?
    @subgroup.sync_subgroup_members(params[:user_ids])
    @options[:include] = [:group_members]
    render json: Api::V1::GroupSerializer.new(@subgroup.reload, @options), status: :accepted
  end

  private

    def set_parent_group
      @parent_group = Group.find(params.expect(:group_id))
    end

    def set_subgroup
      @subgroup = Group.where.not(parent_group_id: nil).find(params.expect(:id))
    end

    def set_options
      @options = { params: { current_user: current_user } }
    end

    def subgroup_params
      params.expect(subgroup: %i[name])
    end
end
