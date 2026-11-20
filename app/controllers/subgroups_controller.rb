# frozen_string_literal: true

class SubgroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :check_manage_access

  def create
    @subgroup = @group.subgroups.new(subgroup_params)
    if @subgroup.save
      redirect_to group_path(@group), notice: t(".success")
    else
      redirect_to group_path(@group), alert: @subgroup.errors.full_messages.to_sentence
    end
  end

  def destroy
    @group.subgroups.find(params.expect(:id)).destroy
    redirect_to group_path(@group), notice: t(".success")
  end

  def update_members
    subgroup = @group.subgroups.find(params.expect(:id))
    target_ids = Array(params[:user_ids]).map(&:to_i) & @group.group_members.pluck(:user_id)
    existing_ids = subgroup.group_members.pluck(:user_id)
    stale_ids = subgroup.group_members.member.pluck(:user_id) - target_ids

    subgroup.group_members.member.where(user_id: stale_ids).destroy_all
    (target_ids - existing_ids).each { |user_id| subgroup.group_members.create(user_id: user_id) }
    subgroup.share_team_project
    redirect_to group_path(subgroup), notice: t(".success")
  end

  def update_team_project
    subgroup = @group.subgroups.find(params.expect(:id))
    if subgroup.update(team_project: Project.find(params.expect(:project_id)))
      subgroup.share_team_project
      redirect_to group_path(subgroup), notice: t(".success")
    else
      redirect_to group_path(subgroup), alert: subgroup.errors.full_messages.to_sentence
    end
  end

  private

    def set_group
      @group = Group.find(params.expect(:group_id))
    end

    def check_manage_access
      authorize @group, :manage_subgroups?
    end

    def subgroup_params
      params.expect(group: [:name])
    end
end
