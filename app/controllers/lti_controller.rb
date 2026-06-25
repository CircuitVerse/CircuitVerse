# frozen_string_literal: true

class LtiController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[launch oidc_login]
  before_action :set_group_and_assignment, only: %i[launch]
  before_action :set_lti_params, only: %i[launch]
  after_action :allow_iframe_lti, only: %i[launch]
  skip_before_action :authenticate_user!, only: %i[launch oidc_login jwks config],
                                          raise: false

  def launch
    if params[:id_token].present?
      handle_lti_13_launch
    else
      handle_lti_11_launch
    end
  end

  def oidc_login
    deployment = LtiDeployment.find_by!(
      platform_id: params.expect(:iss),
      client_id: params.expect(:client_id)
    )

    nonce = SecureRandom.hex(16)
    state = SecureRandom.hex(16)

    session[:lti_nonce] = nonce
    session[:lti_state] = state

    redirect_to build_oidc_redirect(deployment, nonce, state),
                allow_other_host: true
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Unknown LTI platform" }, status: :not_found
  end

  def jwks
    render json: { keys: [Lti::KeyManager.jwk] }
  end

  def tool_config
    render json: {
      title: "CircuitVerse",
      description: "Digital circuit simulator for education",
      target_link_uri: "#{request.base_url}/lti/launch",
      oidc_initiation_url: "#{request.base_url}/lti/login",
      public_jwk_url: "#{request.base_url}/lti/jwks"
    }
  end

  private

    def handle_lti_13_launch
      if session[:lti_state].present? && params[:state] != session[:lti_state]
        render json: { error: "State mismatch" }, status: :unauthorized
        return
      end

      deployment = find_lti_13_deployment(params[:id_token])
      payload    = Lti::JwtValidator.validate!(
        params[:id_token],
        deployment: deployment,
        nonce: session[:lti_nonce]
      )

      @user = find_or_create_user_from_lti13(payload)
      sign_in(@user)

      session.delete(:lti_nonce)
      session.delete(:lti_state)
      session[:is_lti] = true

      redirect_to root_path
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Unknown deployment" }, status: :not_found
    rescue SecurityError, JWT::DecodeError => e
      render json: { error: e.message }, status: :unauthorized
    end

    def handle_lti_11_launch
      session[:is_lti] = true
      if @assignment.blank?
        flash.now[:notice] = t(".notice_no_assignment")
        render :launch_error, status: :unauthorized
        return
      end
      require "oauth/request_proxy/action_controller_request"
      @provider = IMS::LTI::ToolProvider.new(
        params[:oauth_consumer_key],
        @assignment.lti_shared_secret,
        params
      )

      unless @provider.valid_request?(request)
        render :launch_error, status: :unauthorized
        return
      end

      @user = User.find_by(email: @email_from_lms)

      if @user.present?
        if @user.id == @group.primary_mentor_id
          sign_in(@user)
          lms_auth_success_notice = t(".notice_lms_auth_success_teacher",
                                      email_from_lms: @email_from_lms,
                                      lms_type: @lms_type,
                                      course_title_from_lms: @course_title_from_lms)
          redirect_to group_assignment_path(@group, @assignment),
                      notice: lms_auth_success_notice
        elsif GroupMember.exists?(user_id: @user.id, group_id: @group.id)
          flash[:notice] = t(".notice_students_open_in_cv")
          create_project_if_student_present
          render :open_incv, status: :ok
        else
          flash[:notice] = t(".notice_ask_teacher")
          render :launch_error, status: :unauthorized
        end
      else
        flash[:notice] = t(".notice_no_account_in_cv",
                           email_from_lms: @email_from_lms)
        render :launch_error, status: :bad_request
      end
    end

    def find_lti_13_deployment(token)
      payload, _header = JWT.decode(token, nil, false)
      LtiDeployment.find_by!(
        issuer: payload["iss"],
        client_id: Array(payload["aud"]).first
      )
    end

    def find_or_create_user_from_lti13(payload)
      User.find_or_create_by(email: payload["email"]) do |u|
        u.name     = payload["name"] || payload["email"]
        u.password = SecureRandom.hex(16)
      end
    end

    def build_oidc_redirect(deployment, nonce, state)
      uri = URI(deployment.auth_login_url)
      uri.query = URI.encode_www_form(
        response_type: "id_token",
        response_mode: "form_post",
        scope: "openid",
        client_id: deployment.client_id,
        redirect_uri: lti_launch_url,
        login_hint: params[:login_hint],
        lti_message_hint: params[:lti_message_hint],
        nonce: nonce,
        state: state
      )
      uri.to_s
    end

    def set_group_and_assignment
      @assignment = Assignment.find_by(
        lti_consumer_key: params[:oauth_consumer_key]
      )
      @group = @assignment.group if @assignment.present?
    end

    def set_lti_params
      @email_from_lms        = params[:lis_person_contact_email_primary]
      @lms_type              = params[:tool_consumer_info_product_family_code]
      @course_title_from_lms = params[:context_title]
      lms_domain             = params[:launch_presentation_return_url]
      session[:lis_outcome_service_url] = params[:lis_outcome_service_url]
      session[:oauth_consumer_key]      = params[:oauth_consumer_key]
      session[:lms_domain] = URI.join(lms_domain, "/") if lms_domain
    end

    def create_project_if_student_present
      @user    = User.find_by(email: @email_from_lms)
      @project = Project.find_by(author_id: @user.id,
                                 assignment_id: @assignment.id)
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
