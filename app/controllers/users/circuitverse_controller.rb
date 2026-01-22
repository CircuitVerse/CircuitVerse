# frozen_string_literal: true

class Users::CircuitverseController < ApplicationController
  TYPEAHEAD_INSTITUTE_LIMIT = 50

  include UsersCircuitverseHelper

  before_action :authenticate_user!, only: %i[edit update groups]
  before_action :set_user, except: [:typeahead_educational_institute]
  before_action :remove_previous_profile_picture, only: [:update]

  def index
    @profile = ProfileDecorator.new(@user)
    @projects = @user.rated_projects.with_attached_circuit_preview
    @user_projects = @user.projects.with_attached_circuit_preview
    @collaborated_projects = @user.collaborated_projects.with_attached_circuit_preview
  end

  def edit; end

  def typeahead_educational_institute
    query = params[:query].to_s.strip
    return render json: [] if query.blank? || query.length < 2

    institute_list = fetch_educational_institutes(query)
    typeahead_array = institute_list.compact_blank.map { |item| { name: item } }
    render json: typeahead_array
  end

  def update
    if @profile.update(profile_params)
      redirect_to user_projects_path(current_user)
    else
      render :edit
    end
  end

  def groups
    @user = authorize @user
    @groups_owned = Group.where(id: Group.joins(:primary_mentor).where(primary_mentor: @user))
                         .select("groups.*, COUNT(group_members.id) as group_member_count")
                         .left_outer_joins(:group_members)
                         .group("groups.id")
  end

  private

    def fetch_educational_institutes(query)
      sanitized_query = query.gsub(/[^a-zA-Z0-9\s]/, "")
      return [] if sanitized_query.blank?

      # Use full-text search with existing GIN-indexed tsvector column
      # This is much faster than LIKE with leading wildcard
      Rails.cache.fetch("typeahead_institutes/#{sanitized_query.downcase}", expires_in: 5.minutes) do
        User.where("searchable @@ plainto_tsquery('english', ?)", sanitized_query)
            .where.not(educational_institute: [nil, ""])
            .distinct
            .limit(TYPEAHEAD_INSTITUTE_LIMIT)
            .pluck(:educational_institute)
      end
    rescue ActiveRecord::QueryCanceled, ActiveRecord::StatementInvalid => e
      Rails.logger.warn("Typeahead query timeout or error: #{e.message}")
      []
    end

    def profile_params
      params.expect(user: %i[name profile_picture country educational_institute
                             subscribed locale remove_picture avatar vuesim])
    end

    def set_user
      @profile = current_user
      @user = User.find(params[:id])
    end

    def remove_previous_profile_picture
      @profile.profile_picture.purge if params[:user][:profile_picture].present? && @profile.profile_picture.attached?
    end
end
