# frozen_string_literal: true

class OrganizationMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_organizations_feature_flag
  before_action :set_organization
  before_action :set_organization_member, only: %i[update destroy]
  before_action :check_create_access, only: %i[create]
  before_action :check_update_access, only: %i[update]
  before_action :check_destroy_access, only: %i[destroy]

  MAX_INVITES_PER_REQUEST = 50

  # POST /organizations/1/organization_members
  # POST /organizations/1/organization_members.json
  def create
    role = organization_member_params[:role].presence_in(%w[admin mentor member]) || "member"
    submitted = Array(organization_member_params[:emails]).map { |e| e.to_s.strip.downcase }
    valid_emails = submitted.grep(Devise.email_regexp).uniq
    emails = valid_emails.first(MAX_INVITES_PER_REQUEST)
    present_members = User.where(id: @organization.organization_members.select(:user_id)).pluck(:email)
    newly_added = emails - present_members - [current_user&.email&.downcase]
    invite_all(newly_added, role)
    redirect_to members_organization_path(@organization),
                notice: invite_notice(submitted, emails, newly_added, valid_emails.size)
  rescue ActiveRecord::RecordInvalid => e
    redirect_to members_organization_path(@organization), alert: e.message
  rescue ActiveRecord::RecordNotUnique
    redirect_to members_organization_path(@organization), alert: t(".invite_failed")
  end

  # PATCH/PUT /organizations/1/organization_members/1
  # PATCH/PUT /organizations/1/organization_members/1.json
  def update
    respond_to do |format|
      if @organization_member.update(organization_member_update_params)
        format.html { redirect_to members_organization_path(@organization), notice: t(".success") }
        format.json { head :no_content }
      else
        format.html do
          redirect_to members_organization_path(@organization),
                      alert: @organization_member.errors.full_messages.to_sentence
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
      format.html { redirect_to members_organization_path(@organization), notice: t(".success") }
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

    if destroy_membership_safely?
      respond_with_left_organization
    else
      redirect_to members_organization_path(@organization),
                  alert: t("organizations.members.list.leave_blocked_sole_admin")
    end
  rescue Pundit::NotAuthorizedError
    redirect_to members_organization_path(@organization), alert: leave_blocked_reason
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

    def leave_blocked_reason
      membership = @organization.organization_members.find_by(user: current_user)
      if membership&.admin? && @organization.organization_members.where(role: :admin).count <= 1
        t("organizations.members.list.leave_blocked_sole_admin")
      else
        t("organizations.members.list.leave_blocked_primary_mentor")
      end
    end

    def destroy_membership_safely?
      @organization.with_lock do
        return false if @organization_member.admin? &&
                        @organization.organization_members.where(role: :admin).count <= 1

        @organization_member.destroy!
      end
      true
    end

    def respond_with_left_organization
      respond_to do |format|
        format.html { redirect_to organizations_path, notice: t("organization_members.leave.success") }
        format.json { head :no_content }
      end
    end

    def invite_all(emails, role)
      return if emails.empty?

      users_by_email = User.where(email: emails).index_by(&:email)
      role_value = OrganizationMember.roles[role]

      emails.each do |email|
        user = users_by_email[email]
        if user.nil?
          upsert_pending_invitation(email, role_value)
        else
          upsert_membership(user, role_value)
        end
      end
    end

    def upsert_pending_invitation(email, role_value)
      invitation = PendingInvitation.find_or_initialize_by(organization_id: @organization.id, email: email)
      invitation.role = role_value
      invitation.save!
    end

    def upsert_membership(user, role_value)
      membership = @organization.organization_members.find_or_initialize_by(user_id: user.id)
      membership.role = role_value
      membership.save!
    end

    def invite_notice(submitted, emails, newly_added, valid_count)
      total = submitted.count(&:present?)
      notice = t(
        "organization_members.create.invite_summary",
        count: total,
        invited: newly_added.size,
        invalid: total - valid_count,
        already: emails.size - newly_added.size
      )
      skipped = valid_count - emails.size
      return notice if skipped.zero?

      "#{notice} #{t('organization_members.create.limit_exceeded', limit: MAX_INVITES_PER_REQUEST, skipped: skipped)}"
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
