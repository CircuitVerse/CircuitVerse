# frozen_string_literal: true

class LtiController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :launch # for lti integration
  before_action :set_group_and_assignment, only: %i[launch]
  before_action :set_lti_params, only: %i[launch]
  after_action :allow_iframe_lti, only: %i[launch]

  def launch
    session[:is_lti] = true # the lti session starting
    if @assignment.blank?
      # if no assignment is found
      flash[:notice] = t("lti.launch.notice_no_assignment")
      render :launch_error, status: :unauthorized
      return
    end
    require "oauth/request_proxy/action_controller_request"
    @provider = IMS::LTI::ToolProvider.new(
      params[:oauth_consumer_key], # lms_oauth_consumer_key
      @assignment.lti_shared_secret, # the group's lti_token
      params
    )

    unless @provider.valid_request?(request) # checking the lti request from the lms end
      render :launch_error, status: :unauthorized
      return
    end
    # find user by matching email with circuitverse and lms
    @user = User.find_by(email: @email_from_lms)

    if @user.present? # user is present in cv
      if @user.id == @group.mentor_id # user is teacher
        # passwordless sign_in the user as the authenticity is verified via lms
        sign_in(@user)
        lms_auth_success_notice = t("lti.launch.notice_lms_auth_success_teacher",
                                    email_from_lms: @email_from_lms,
                                    lms_type: @lms_type,
                                    course_title_from_lms: @course_title_from_lms)
        # if auth_success send to group page
        redirect_to group_assignment_path(@group, @assignment), notice: lms_auth_success_notice
      elsif GroupMember.exists?(
        user_id: @user.id,
        group_id: @group.id
      ) # user is member of the group
        flash[:notice] = t("lti.launch.notice_students_open_in_cv")
        create_project_if_student_present # create project with lis_result_sourced_id
        render :open_incv, status: :ok
      else # user is not a member of the group
        flash[:notice] = t("lti.launch.notice_ask_teacher")
        render :launch_error, status: :unauthorized
      end
    else # no such user in circuitverse
      flash[:notice] = t("lti.launch.notice_no_account_in_cv", email_from_lms: @email_from_lms)
      render :launch_error, status: :bad_request
    end
  end

  private

    def set_group_and_assignment
      @assignment = Assignment.find_by(lti_consumer_key: params[:oauth_consumer_key])
      @group = @assignment.group if @assignment.present?
    end

    def set_lti_params
      # get some of the parameters from the lti request
      @email_from_lms = params[:lis_person_contact_email_primary] # user email
      @lms_type = params[:tool_consumer_info_product_family_code] # lms type
      @course_title_from_lms = params[:context_title] # course title
      lms_domain = params[:launch_presentation_return_url]
      session[:lis_outcome_service_url] = params[:lis_outcome_service_url] # grading parameters
      session[:oauth_consumer_key] = params[:oauth_consumer_key] # grading parameters
      session[:lms_domain] = URI.join lms_domain, "/" if lms_domain # set in session
    end

    def create_project_if_student_present
      @user = User.find_by(email: @email_from_lms)
      # find if the project is already present
      @project = Project.find_by(author_id: @user.id, assignment_id: @assignment.id)
      return if @project.present?

      @project = @user.projects.create(
        name: "#{@user.name}/#{@assignment.name}",
        assignment_id: @assignment.id,
        project_access_type: "Private",
        lis_result_sourced_id: params[:lis_result_sourcedid]
      )
      @project.build_project_datum
      @project.save
    end

    def allow_iframe_lti
      return unless session[:is_lti]

      response.headers["X-FRAME-OPTIONS"] = "ALLOW-FROM #{session[:lms_domain]}"
    end
end
