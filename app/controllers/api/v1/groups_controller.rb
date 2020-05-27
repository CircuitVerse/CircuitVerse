# frozen_string_literal: true

class Api::V1::GroupsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_group, except: %i[index groups_mentored create]
  before_action :check_show_access, only: [:show]
  before_action :check_edit_access, only: %i[update destroy]

  ALLOWED_TO_BE_INCLUDED = %i[group_members assignments].freeze

  # GET /api/v1/groups
  def index
    raise ActiveRecord::RecordNotFound if @current_user.groups.empty?

    @groups = paginate(@current_user.groups)
    @options = { links: link_attrs(@groups, api_v1_groups_url) }
    @options[:include] = include_resource if params.key?(:include)
    render json: Api::V1::GroupSerializer.new(@groups, @options)
  end

  # GET /api/v1/groups_mentored
  def groups_mentored
    raise ActiveRecord::RecordNotFound if @current_user.groups_mentored.empty?

    @groups = paginate(@current_user.groups_mentored)
    @options = { links: link_attrs(@groups, api_v1_groups_mentored_url) }
    @options[:include] = include_resource if params.key?(:include)
    render json: Api::V1::GroupSerializer.new(@groups, @options)
  end

  # POST /api/v1/groups/
  def create
    @group = @current_user.groups_mentored.new(group_params)
    @group.save!
    if @group.save
      @options = { include: include_resource } if params.key?(:include)
      render json: Api::V1::GroupSerializer.new(@group, @options || {}), status: :created
    else
      invalid_resource!(@group.errors)
    end
  end

  # GET /api/v1/groups/:id
  def show
    @options = { include: include_resource } if params.key?(:include)
    render json: Api::V1::GroupSerializer.new(@group, @options || {})
  end

  # PATCH /api/v1/groups/:id
  def update
    @group.update!(group_params)
    if @group.update(group_params)
      render json: Api::V1::GroupSerializer.new(@group), status: :accepted
    else
      invalid_resource!(@group.errors)
    end
  end

  # DELETE /api/v1/groups/:id
  def destroy
    @group.destroy!
    render json: {}, status: :no_content
  end

  private

    # include=group_members,assignments
    def include_resource
      params[:include].split(",")
                      .map { |resource| resource.strip.to_sym }
                      .select { |resource| ALLOWED_TO_BE_INCLUDED.include?(resource) }
    end

    def set_group
      @group = Group.find(params[:id])
    end

    def group_params
      params.require(:group).permit(:name, :mentor_id)
    end

    def check_show_access
      authorize @group, :show_access?
    end

    def check_edit_access
      authorize @group, :admin_access?
    end
end
