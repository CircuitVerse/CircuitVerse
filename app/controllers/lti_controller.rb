# frozen_string_literal: true

class LtiController < ApplicationController
  # The state is signed rather than kept in the session: the launch returns as a
  # cross-site POST that a SameSite cookie would not survive, and the signature
  # is what proves the launch answers an initiation we made.
  LTI_STATE_PURPOSE = "lti.launch.state"
  LTI_STATE_TTL = 5.minutes

  # The LMS initiates the login, so it cannot send a CSRF token of ours.
  skip_before_action :verify_authenticity_token, only: %i[launch oidc_login] # for lti integration
  before_action :set_group_and_assignment, only: %i[launch]
  before_action :set_lti_params, only: %i[launch]
  before_action :verify_lti_advantage_enabled, only: %i[oidc_login]
  after_action :allow_iframe_lti, only: %i[launch]

  # Step 1 of the LTI 1.3 handshake; the launch verifies the nonce and state.
  def oidc_login
    deployment = find_oidc_deployment
    return head :not_found if deployment.blank?

    nonce = SecureRandom.hex(16)
    state = lti_state_verifier.generate(
      { "nonce" => nonce, "deployment_id" => deployment.id },
      purpose: LTI_STATE_PURPOSE,
      expires_in: LTI_STATE_TTL
    )

    redirect_to oidc_authorize_url(deployment, nonce, state), allow_other_host: true
  end

  def launch
    session[:is_lti] = true # the lti session starting
    if @assignment.blank?
      # if no assignment is found
      flash.now[:notice] = t(".notice_no_assignment")
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
    store_lti_11_grade_context
    # find user by matching email with circuitverse and lms
    @user = User.find_by(email: @email_from_lms)

    if @user.present? # user is present in cv
      if @user.id == @group.primary_mentor_id # user is teacher
        # passwordless sign_in the user as the authenticity is verified via lms
        sign_in(@user)
        lms_auth_success_notice = t(".notice_lms_auth_success_teacher",
                                    email_from_lms: @email_from_lms,
                                    lms_type: @lms_type,
                                    course_title_from_lms: @course_title_from_lms)

        redirect_to group_assignment_path(@group, @assignment), notice: lms_auth_success_notice
      elsif GroupMember.exists?(
        user_id: @user.id,
        group_id: @group.id
      ) # user is member of the group
        flash[:notice] = t(".notice_students_open_in_cv")
        create_project_if_student_present # create project with lis_result_sourced_id
        render :open_incv, status: :ok
      else # user is not a member of the group
        flash[:notice] = t(".notice_ask_teacher")
        render :launch_error, status: :unauthorized
      end
    else # no such user in circuitverse
      flash[:notice] = t(".notice_no_account_in_cv", email_from_lms: @email_from_lms)
      render :launch_error, status: :bad_request
    end
  end

  private

    # LTI 1.3 stays dark until an operator opts in; LTI 1.1 is unaffected.
    def verify_lti_advantage_enabled
      head :not_found unless Flipper.enabled?(:lti_advantage)
    end

    # iss and login_hint are required on every initiation; the optional claims
    # only narrow the lookup when a platform registers CircuitVerse twice.
    def find_oidc_deployment
      return nil if params[:iss].blank? || params[:login_hint].blank?

      scope = LtiDeployment.where(issuer: params[:iss])
      scope = scope.where(client_id: params[:client_id]) if params[:client_id].present?
      scope = scope.where(deployment_id: params[:lti_deployment_id]) if params[:lti_deployment_id].present?
      scope.order(:id).first
    end

    def oidc_authorize_url(deployment, nonce, state)
      uri = URI(deployment.auth_login_url)
      uri.query = URI.encode_www_form(
        scope: "openid",
        response_type: "id_token",
        response_mode: "form_post",
        prompt: "none",
        client_id: deployment.client_id,
        redirect_uri: "#{request.base_url}/lti/launch",
        login_hint: params[:login_hint],
        lti_message_hint: params[:lti_message_hint],
        nonce: nonce,
        state: state
      )
      uri.to_s
    end

    def lti_state_verifier
      Rails.application.message_verifier(LTI_STATE_PURPOSE)
    end

    def set_group_and_assignment
      @assignment = Assignment.find_by(lti_consumer_key: params[:oauth_consumer_key])
      @group = @assignment.group if @assignment.present?
    end

    def set_lti_params
      # get some of the parameters from the lti request
      clear_lti_11_grade_context
      @email_from_lms = params[:lis_person_contact_email_primary] # user email
      @lms_type = params[:tool_consumer_info_product_family_code] # lms type
      @course_title_from_lms = params[:context_title] # course title
      lms_domain = params[:launch_presentation_return_url]
      session[:lms_domain] = URI.join lms_domain, "/" if lms_domain # set in session
    end

    def store_lti_11_grade_context
      return unless @assignment.present? && params[:lis_outcome_service_url].present?

      session[:lis_outcome_service_url] = params[:lis_outcome_service_url]
      session[:oauth_consumer_key] = params[:oauth_consumer_key]
      session[:lti_11_assignment_id] = @assignment.id
    end

    def clear_lti_11_grade_context
      session.delete(:lis_outcome_service_url)
      session.delete(:oauth_consumer_key)
      session.delete(:lti_11_assignment_id)
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
