# frozen_string_literal: true

class SubgroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_parent_group
  before_action :check_manage_access
  before_action :set_subgroup, only: %i[destroy update_members]

  # POST /groups/:group_id/subgroups
  def create
    @subgroup = @parent_group.subgroups.new(subgroup_params)

    if @subgroup.save
      redirect_to group_path(@parent_group), notice: t(".notice_created")
    else
      redirect_to group_path(@parent_group),
                  alert: @subgroup.errors.full_messages.to_sentence
    end
  end

  # DELETE /groups/:group_id/subgroups/:id
  def destroy
    @subgroup.destroy
    redirect_to group_path(@parent_group), notice: t(".notice_deleted")
  end

  # PATCH /groups/:group_id/subgroups/:id/update_members
  # Syncs the subgroup's (non-mentor) membership to the submitted user ids,
  # which are restricted to members of the parent group.
  def update_members
    user_ids = Array(params[:user_ids]).map(&:to_i)
    allowed_ids = @parent_group.group_members.pluck(:user_id)
    target_ids = user_ids & allowed_ids

    current_member_ids = @subgroup.group_members.member.pluck(:user_id)
    # Mentor rows are managed via the mentors flow, so the checkbox sync must
    # neither remove them nor try to insert a duplicate row for them.
    existing_ids = @subgroup.group_members.pluck(:user_id)

    @subgroup.group_members.member.where(user_id: current_member_ids - target_ids).destroy_all
    (target_ids - existing_ids).each do |user_id|
      @subgroup.group_members.create(user_id: user_id)
    end

    redirect_to group_path(@subgroup), notice: t(".notice_updated")
  end

  private

    def set_parent_group
      @parent_group = Group.find(params.expect(:group_id))
    end

    def set_subgroup
      @subgroup = @parent_group.subgroups.find(params.expect(:id))
    end

    def check_manage_access
      authorize @parent_group, :manage_subgroups?
    end

    def subgroup_params
      params.expect(group: %i[name])
    end
end
