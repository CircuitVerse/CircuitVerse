# frozen_string_literal: true

class Api::V1::GroupsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_group, except: %i[index groups_owned create]
  before_action :set_options, only: %i[index groups_owned create show update]
  before_action :check_show_access, only: [:show]
  before_action :check_edit_access, only: %i[update destroy]

  WHITELISTED_INCLUDE_ATTRIBUTES = %i[group_members assignments].freeze

  # GET /api/v1/groups
  def index
    @groups = paginate(current_user.groups)
    @options[:links] = link_attrs(@groups, api_v1_groups_url)
    render json: Api::V1::GroupSerializer.new(@groups, @options)
  end

  # GET /api/v1/groups/owned
  def groups_owned
    @groups = paginate(current_user.groups_owned)
    @options[:links] = link_attrs(@groups, api_v1_groups_owned_url)
    render json: Api::V1::GroupSerializer.new(@groups, @options)
  end

  # GET /api/v1/groups/:id
  def show
    render json: Api::V1::GroupSerializer.new(@group, @options)
  end

  # POST /api/v1/groups/
  def create
    @group = current_user.groups_owned.new(group_params)
    @group.save!
    if @group.save
      render json: Api::V1::GroupSerializer.new(@group, @options), status: :created
    else
      invalid_resource!(@group.errors)
    end
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
    head :no_content
  end

  private

    # include=group_members,assignments
    def include_resource
      params[:include].split(",")
                      .map { |resource| resource.strip.to_sym }
                      .select { |resource| WHITELISTED_INCLUDE_ATTRIBUTES.include?(resource) }
    end

    def set_group
      @group = Group.find(params[:id])
    end

    def set_options
      @options = {}
      @options[:include] = include_resource if params.key?(:include)
      @options[:params] = { current_user: current_user }
    end

    def group_params
      params.expect(group: %i[name primary_mentor_id])
    end

    def check_show_access
      authorize @group, :show_access?
    end

    def check_edit_access
      authorize @group, :admin_access?
    end
end
