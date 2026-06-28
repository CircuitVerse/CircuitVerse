# frozen_string_literal: true

class OrganizationMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_organizations_feature_flag
  before_action :set_organization
  before_action :set_organization_member, only: %i[update destroy]
  before_action :check_create_access, only: %i[create]
  before_action :check_update_access, only: %i[update]
  before_action :check_destroy_access, only: %i[destroy]
  before_action :check_index_access, only: %i[index]

  def index
    @organization_members = @organization.organization_members.includes(:user)

    if params[:role].present? && OrganizationMember.roles.key?(params[:role])
      @organization_members = @organization_members.where(role: params[:role])
    end

    @organization_members = if params[:sort] == "newest"
      @organization_members.order(created_at: :desc)
    elsif params[:sort] == "oldest"
      @organization_members.order(created_at: :asc)
    else
      @organization_members.joins(:user).order(role: :asc, "users.name" => :asc)
    end

    @organization_members = @organization_members.paginate(page: params[:page], per_page: 15)
  end

  # POST /organizations/1/organization_members
  # POST /organizations/1/organization_members.json
  def create
    role   = params.dig(:organization_member, :role).presence || "member"
    notice = process_member_emails(role)

    respond_to do |format|
      format.html { redirect_to organization_organization_members_path(@organization), notice: notice }
      format.json { render json: { message: notice }, status: :created }
    end
  end

  # PATCH/PUT /organizations/1/organization_members/1
  # PATCH/PUT /organizations/1/organization_members/1.json
  def update
    respond_to do |format|
      if @organization_member.update(organization_member_update_params)
        format.html { redirect_to organization_organization_members_path(@organization), notice: t(".success") }
        format.json { head :no_content }
      else
        format.html do
          redirect_to organization_organization_members_path(@organization),
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
      format.html { redirect_to organization_organization_members_path(@organization), notice: t(".success") }
      format.json { head :no_content }
    end
  end

  # DELETE /organizations/1/leave
  # DELETE /organizations/1/leave.json
  def leave
    @organization_member = @organization.organization_members.find_by!(user: current_user)
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

    def organization_member_update_params
      params.expect(organization_member: [:role])
    end

    def process_member_emails(role)
      emails_raw = params.dig(:organization_member, :emails).to_s
      emails = emails_raw.split(/[,\s]+/).map(&:strip).compact_blank
      added, not_found, already_member = categorize_emails(emails, role)
      build_notice(added, not_found, already_member, emails)
    end

    def categorize_emails(emails, role)
      added = []
      not_found = []
      already_member = []

      emails.each do |email|
        user = User.find_by(email: email)
        if user.nil?
          not_found << email
        elsif @organization.organization_members.exists?(user_id: user.id)
          already_member << email
        else
          @organization.organization_members.create!(user: user, role: role)
          added << email
        end
      end

      [added, not_found, already_member]
    end

    def build_notice(added, not_found, already_member, emails)
      parts = []
      parts << "Added #{added.size} member(s)." if added.any?
      parts << "Not found in CircuitVerse: #{not_found.join(', ')}." if not_found.any?
      parts << "Already a member: #{already_member.join(', ')}." if already_member.any?
      parts << "No emails provided." if emails.empty?
      parts.join(" ")
    end

    def check_organizations_feature_flag
      return if Flipper.enabled?(:organizations, current_user)

      redirect_to root_path, alert: t("feature_not_available")
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

    def check_index_access
      authorize @organization, :show_access?
    end
end
