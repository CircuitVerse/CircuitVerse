# frozen_string_literal: true

class OrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_organizations_feature_flag
  before_action :set_organization,
                only: %i[show overview members settings update destroy generate_invite_token confirm_join join]
  before_action :check_show_access, only: %i[show overview members]
  before_action :check_edit_access, only: %i[settings update destroy]
  before_action :check_admin_access, only: %i[generate_invite_token]

  PER_PAGE = 9
  MEMBERS_PER_PAGE = 20

  # GET /organizations
  def index
    @organizations = if params[:explore].present?
      Organization.where(private: false).order(created_at: :desc).paginate(page: params[:page], per_page: PER_PAGE)
    else
      current_user.organizations.order(created_at: :desc).paginate(page: params[:page], per_page: PER_PAGE)
    end
  end

  # GET /organizations/1  → redirect to overview tab
  def show
    redirect_to overview_organization_path(@organization)
  end

  # GET /organizations/1/overview
  def overview
    @active_tab = "overview"
    @groups = @organization.groups
                           .left_joins(:group_members)
                           .select("groups.*, COUNT(group_members.id) AS group_members_count")
                           .group("groups.id")
                           .order(created_at: :desc)
                           .paginate(
                             page: params[:groups_page],
                             per_page: PER_PAGE,
                             total_entries: @organization.groups.count
                           )
  end

  # GET /organizations/1/members
  # (members tab content is added in a follow-up PR)
  def members
    @active_tab = "members"
    @sort_column = params.expect(:sort).presence_in(%w[name role created_at]) || "role"
    @sort_direction = params.expect(:direction).presence_in(%w[asc desc]) || "asc"

    members = @organization.organization_members.includes(:user)
    sorted =
      case @sort_column
      when "name"
        members.joins(:user).order("users.name #{@sort_direction}")
      when "created_at"
        members.order("organization_members.created_at #{@sort_direction}")
      else
        members.order("organization_members.role #{@sort_direction}")
      end

    @organization_members = sorted.paginate(page: params[:members_page], per_page: MEMBERS_PER_PAGE)
  end

  # GET /organizations/1/settings
  # (settings tab content is added in a follow-up PR)
  def settings
    @active_tab = "settings"
  end

  # GET /organizations/new
  def new
    @organization = Organization.new
  end

  # GET /organizations/check_slug
  def check_slug
    base_slug = (params[:slug].presence || params[:name]).to_s.strip.parameterize
    is_taken = base_slug.present? && Organization.exists?(slug: base_slug)

    render json: { slug: base_slug, available: base_slug.present? && !is_taken }
  end

  # POST /organizations
  def create
    @organization = Organization.new(organization_params)

    respond_to do |format|
      if create_organization
        format.html { redirect_to overview_organization_path(@organization), notice: t(".success") }
        format.json { render :show, status: :created, location: @organization }
      else
        flash.now[:alert] = t(".failure")
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @organization.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /organizations/1
  def update
    respond_to do |format|
      if @organization.update(organization_params)
        format.html { redirect_to overview_organization_path(@organization), notice: t(".success") }
        format.json { render :show, status: :ok, location: @organization }
      else
        format.html { render :settings, status: :unprocessable_content }
        format.json { render json: @organization.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /organizations/1
  def destroy
    if params[:confirmation] != @organization.name
      respond_to do |format|
        format.html { redirect_to settings_organization_path(@organization), alert: t(".confirmation_mismatch") }
        format.json { render json: { error: t(".confirmation_mismatch") }, status: :unprocessable_content }
      end
      return
    end

    @organization.destroy
    respond_to do |format|
      format.html { redirect_to organizations_path, notice: t(".success") }
      format.json { head :no_content }
    end
  end

  def confirm_join
    # GET just show a confirmation page, no mutation
    return if Organization.exists?(id: @organization.id, invite_token: params[:token])

    redirect_to root_path, alert: t("organization_members.join.invalid") and return

    # renders confirm_join.html.erb with a "Join" button that POSTs
  end

  def join
    case @organization.add_member_from_invite(current_user, params[:token])
    when :joined
      notice = t("organization_members.join.success")
    when :already_member
      notice = t("organization_members.join.already_member")
    when :invalid_or_expired
      notice = invite_token_error_notice
    end
    redirect_to overview_organization_path(@organization), notice: notice
  end

  def generate_invite_token
    role = params.expect(:role).presence_in(%w[admin mentor member]) || "member"
    @organization.reset_invite_token(role: role)
    respond_to do |format|
      format.js
      format.html { redirect_to members_organization_path(@organization) }
    end
  end

  private

    def set_organization
      @organization = Organization.friendly.find(params.expect(:id))
    end

    def organization_params
      params.expect(organization: [:name, :slug, :description, :location, :private, :logo, :remove_logo, { links: [] }])
    end

    def check_organizations_feature_flag
      return if Flipper.enabled?(:organizations, current_user)

      redirect_to root_path, alert: t("feature_not_available")
    end

    def check_show_access
      authorize @organization, :show_access?
    end

    def check_edit_access
      authorize @organization, :admin_access?
    end

    def check_admin_access
      authorize @organization, :admin_access?
    end

    def invite_token_error_notice
      if Organization.exists?(id: @organization.id, invite_token: params[:token])
        t("organization_members.join.expired")
      else
        t("organization_members.join.invalid")
      end
    end

    def create_organization
      ActiveRecord::Base.transaction do
        if @organization.save
          @organization.organization_members.create!(user: current_user, role: :admin)
          true
        else
          false
        end
      rescue ActiveRecord::RecordInvalid => e
        @organization.errors.add(:base, e.message)
        raise ActiveRecord::Rollback
      end
    end
end
