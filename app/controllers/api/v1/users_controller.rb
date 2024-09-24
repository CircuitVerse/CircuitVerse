# frozen_string_literal: true

class Api::V1::UsersController < Api::V1::BaseController
  before_action :set_user, only: %i[show update]
  before_action :authenticate_user!
  before_action :check_access, only: [:update]
  before_action :set_details_access, except: %i[index me]
  before_action :check_admin, only: [:add_moderators]

  # GET api/v1/users
  def index
    @users = paginate(User.all)
    @options = { params: { only_name: true } }
    @options[:links] = link_attrs(@users, api_v1_users_url)
    render json: Api::V1::UserSerializer.new(@users, @options)
  end

  # GET api/v1/users/:id
  def show
    render json: Api::V1::UserSerializer.new(@user, @options)
  end

  # GET api/v1/me
  def me
    @options = { params: { has_details_access: true } }
    render json: Api::V1::UserSerializer.new(current_user, @options)
  end

  # PATCH api/v1/users/:id
  def update
    @user.update!(user_params)
    if @user.update(user_params)
      render json: Api::V1::UserSerializer.new(@user, @options), status: :accepted
    else
      invalid_resource!(@user.errors)
    end
  end

  # POST api/v1/users/add_moderators
  def add_moderators
    emails = params[:emails].split(",").map(&:strip)
    users = User.where(email: emails)

    users.each do |user|
      user.update(question_bank_moderator: true)
    end

    if users.all? { |user| user.errors.empty? }
      redirect_back(fallback_location: root_path)
    else
      render json: { errors: users.map(&:errors).flat_map(&:full_messages) }, status: :unprocessable_entity
    end
  end

  # GET api/v1/users/manage_moderators
  def manage_moderators
    @moderators = User.where(question_bank_moderator: true)
    return unless params[:remove_moderator_id]

    moderator = User.find_by(id: params[:remove_moderator_id])
    if moderator.present?
      moderator.update(question_bank_moderator: false)
    else
      flash[:alert] = "Moderator not found."
    end
  end

  def my_questions
    @user = current_user
    submitted_questions = QuestionSubmissionHistory.where(user_id: @user.id)
    filtered_submissions = submitted_questions.select do |submission|
      submission.status.in?(%w[attempted solved])
    end
    question_ids = filtered_submissions.map(&:question_id)
    @questions = Question.where(id: question_ids)
    render json: @questions
  end

  private

    def set_user
      @user = User.find(params[:id])
    end

    def check_access
      authorize @user, :edit?
    end

    def check_admin
      return if current_user.admin?

      render json: { error: "Access denied" }, status: :forbidden
    end

    def set_details_access
      @options = { params: { has_details_access: @user.eql?(current_user) } }
    end

    def user_params
      params.permit(:name, :locale, :educational_institute, :country, :subscribed,
                    :profile_picture, :remove_picture)
    end
end
