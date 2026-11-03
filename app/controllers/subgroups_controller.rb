# frozen_string_literal: true

class SubgroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :check_manage_access
  before_action :check_subgroups_available

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

  private

    def set_group
      @group = Group.find(params.expect(:group_id))
    end

    def check_manage_access
      authorize @group, :manage_subgroups?
    end

    # The subgroups data layer (Group#subgroups, parent_group_id) ships in a
    # separate, still-unmerged PR; this keeps that gap from surfacing as an
    # unhandled NoMethodError/500.
    def check_subgroups_available
      return if @group.respond_to?(:subgroups)

      redirect_to group_path(@group), alert: t("subgroups.not_available")
    end

    def subgroup_params
      params.expect(group: [:name])
    end
end
