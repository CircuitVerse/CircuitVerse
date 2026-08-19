# frozen_string_literal: true

class OrganizationMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_organizations_feature_flag
  before_action :set_organization
  before_action :set_organization_member, only: %i[update destroy]
  before_action :check_create_access, only: %i[create]
  before_action :check_update_access, only: %i[update]
  before_action :check_destroy_access, only: %i[destroy]

  # POST /organizations/1/organization_members
  # POST /organizations/1/organization_members.json
  def create
    role = organization_member_params[:role].presence_in(%w[admin mentor member]) || "member"
    emails = Array(organization_member_params[:emails]).grep(Devise.email_regexp)
    present_members = User.where(id: @organization.organization_members.pluck(:user_id)).pluck(:email)
    newly_added = emails - present_members - [current_user&.email]
    newly_added.each { |email| invite_by_email(email.strip, role) }
    notice = Utils.mail_notice(Array(organization_member_params[:emails]), emails, newly_added)
    redirect_to members_organization_path(@organization), notice: notice
  end

  # PATCH/PUT /organizations/1/organization_members/1
  # PATCH/PUT /organizations/1/organization_members/1.json
  def update
    respond_to do |format|
      if @organization_member.update(organization_member_update_params)
        format.html { redirect_to @organization, notice: t(".success") }
        format.json { head :no_content }
      else
        format.html do
          redirect_to @organization, alert: @organization_member.errors.full_messages.to_sentence
        end
        format.json { render json: @organization_member.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /organizations/1/organization_members/1
  # DELETE /organizations/1/organization_members/1.json
  def destroy
    @organization_member.destroy
    respond_to do |format|
      format.html { redirect_to @organization, notice: t(".success") }
      format.json { head :no_content }
    end
  end

  # DELETE /organizations/1/leave
  # DELETE /organizations/1/leave.json
  def leave
    @organization_member = @organization.organization_members.find_by(user: current_user)

    if @organization_member.nil?
      redirect_to organizations_path, alert: t(".not_a_member")
      return
    end

    authorize @organization, :leave?

    @organization_member.destroy
    respond_to do |format|
      format.html { redirect_to organizations_path, notice: t(".success") }
      format.json { head :no_content }
    end
  end

  private

    def set_organization
      @organization = Organization.friendly.find(params.expect(:organization_id))
    end

    def set_organization_member
      @organization_member = @organization.organization_members.find(params.expect(:id))
    end

    def organization_member_params
      params.expect(organization_member: [:role, { emails: [] }])
    end

    def organization_member_update_params
      params.expect(organization_member: [:role])
    end

    def check_organizations_feature_flag
      return if Flipper.enabled?(:organizations, current_user)

      redirect_to root_path, alert: t("feature_not_available")
    end

    def invite_by_email(email, role)
      user = User.find_by(email: email)
      if user.nil?
        PendingInvitation.create_or_find_by!(organization_id: @organization.id, email: email) do |invite|
          invite.role = OrganizationMember.roles[role]
        end
      else
        @organization.organization_members
                     .where(user_id: user.id)
                     .first_or_create!(role: OrganizationMember.roles[role])
      end
    end

    def check_create_access
      authorize @organization, :admin_access?
    end

    def check_update_access
      authorize @organization_member, :update?
    end

    def check_destroy_access
      authorize @organization_member, :destroy?
    end
end
