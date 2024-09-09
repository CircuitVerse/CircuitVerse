# frozen_string_literal: true

class Users::CircuitverseController < ApplicationController
  TYPEAHEAD_INSTITUTE_LIMIT = 50

  include UsersCircuitverseHelper

  before_action :authenticate_user!, only: %i[edit update groups]
  before_action :set_user, except: [:typeahead_educational_institute]
  before_action :remove_previous_profile_picture, only: [:update]

  def index
    @moderators = User.where(question_bank_moderator: true)
    @profile = ProfileDecorator.new(@user)
    @projects = @user.rated_projects
    
    # @user = current_user
    # submitted_questions = QuestionSubmissionHistory.where(user_id: @user.id)
    @question_submission_histories = QuestionSubmissionHistory.where(user_id: @profile.id)


    # filtered_submissions = QuestionSubmissionHistory.where(user_id: @user.id)
    # filtered_submissions_profile = QuestionSubmissionHistory.where(user_id: @profile.id)

    question_ids = @question_submission_histories.map(&:question_id)
    # question_ids_profile = filtered_submissions_profile.map(&:question_id)
    @questions = Question.where(id: question_ids)
    # @questions_profile = Question.where(id: question_ids_profile)
    @categories = QuestionCategory.all
    # @question_submission_histories = QuestionSubmissionHistory.where(user_id: current_user.id).index_by(&:question_id)
    # @question_submission_histories_profile = QuestionSubmissionHistory.where(user_id: @profile.id).index_by(&:question_id)
    
  end

  def edit; end

  def typeahead_educational_institute
    query = params[:query]
    institute_list = User.where("educational_institute LIKE :query", query: "%#{query}%")
                         .distinct
                         .limit(TYPEAHEAD_INSTITUTE_LIMIT)
                         .pluck(:educational_institute)
    typeahead_array = institute_list.map { |item| { name: item } }
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

  def toggle_privacy
    if current_user
      current_user.update(public: !current_user.public)
      redirect_to user_path(current_user), notice: 'Privacy setting updated successfully.'
    else
      redirect_to new_user_session_path, alert: 'You need to sign in or sign up before continuing.'
    end
  end

  private

    def profile_params
      params.require(:user).permit(:name, :profile_picture, :country, :educational_institute,
                                   :subscribed, :locale, :remove_picture, :avatar, :vuesim)
    end

    def set_user
      @profile = current_user
      @user = User.find(params[:id])
    end

    def remove_previous_profile_picture
      @profile.profile_picture.purge if params[:user][:profile_picture].present? && @profile.profile_picture.attached?
    end
end
