# frozen_string_literal: true

class OrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_organizations_feature_flag
  before_action :set_organization, only: %i[show overview members settings update destroy]
  before_action :check_show_access, only: %i[show overview members]
  before_action :check_edit_access, only: %i[settings update destroy]
  before_action :set_user_organizations, only: %i[overview members settings]

  PER_PAGE = 9

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
    @organization.destroy
    respond_to do |format|
      format.html { redirect_to organizations_path, notice: t(".success") }
      format.json { head :no_content }
    end
  end

  private

    def set_organization
      @organization = Organization.friendly.find(params.expect(:id))
    end

    def organization_params
      params.expect(organization: [:name, :slug, :description, :location, :private, :logo, :remove_logo, { links: [] }])
    end

    def set_user_organizations
      memberships = current_user.organization_members.includes(:organization)
      group_counts = Group.where(organization_id: memberships.map(&:organization_id))
                          .group(:organization_id)
                          .count

      @user_organizations = memberships.map do |membership|
        {
          organization: membership.organization,
          role: membership.role,
          group_count: group_counts.fetch(membership.organization_id, 0)
        }
      end
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
