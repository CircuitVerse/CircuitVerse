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
    subgroup.sync_subgroup_members(params[:user_ids])
    redirect_to group_path(subgroup), notice: t(".success")
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
