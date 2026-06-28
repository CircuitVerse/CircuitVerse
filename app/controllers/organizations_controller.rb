# frozen_string_literal: true

class OrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_organizations_feature_flag
  before_action :set_organization, only: %i[show edit update destroy]
  before_action :check_show_access, only: %i[show]
  before_action :check_edit_access, only: %i[edit update destroy]

  # GET /organizations
  def index
    @organizations = if params[:explore].present?
      Organization.where(private: false).order(created_at: :desc).paginate(page: params[:page], per_page: 9)
    else
      current_user.organizations.order(created_at: :desc).paginate(page: params[:page], per_page: 9)
    end
  end

  # GET /organizations/1
  def show
    @groups = @organization.groups.order(created_at: :desc).paginate(page: params[:groups_page], per_page: 9)

    @members = @organization.organization_members.joins(:user)

    if params[:role].present? && OrganizationMember.roles.key?(params[:role])
      @members = @members.where(role: params[:role])
    end

    if params[:q].present?
      @members = @members.where("users.name ILIKE ?", "%#{params[:q]}%")
    end

    @members = @members.order(role: :asc, "users.name" => :asc).paginate(page: params[:members_page], per_page: 10)
  end

  # GET /organizations/new
  def new
    @organization = Organization.new
  end

  # GET /organizations/check_slug
  def check_slug
    name = params[:name].to_s.strip
    base_slug = name.parameterize
    is_taken = base_slug.present? && Organization.exists?(slug: base_slug)

    render json: { slug: base_slug, available: base_slug.present? && !is_taken }
  end

  # GET /organizations/1/edit
  def edit; end

  # POST /organizations
  # POST /organizations.json
  def create
    @organization = Organization.new(organization_params)

    respond_to do |format|
      if create_organization
        format.html { redirect_to @organization, notice: t(".success") }
        format.json { render :show, status: :created, location: @organization }
      else
        flash.now[:alert] = t(".failure")
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @organization.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /organizations/1
  # PATCH/PUT /organizations/1.json
  def update
    respond_to do |format|
      if @organization.update(organization_params)
        format.html { redirect_to @organization, notice: t(".success") }
        format.json { render :show, status: :ok, location: @organization }
      else
        format.html { render :edit }
        format.json { render json: @organization.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /organizations/1
  # DELETE /organizations/1.json
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
      params.expect(organization: [:name, :description, :location, :private, :logo, :remove_logo, { links: [] }])
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
