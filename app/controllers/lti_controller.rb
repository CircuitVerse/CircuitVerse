# frozen_string_literal: true

class LtiController < ApplicationController
  DEPLOYMENT_ID_CLAIM = "https://purl.imsglobal.org/spec/lti/claim/deployment_id"

  # The OIDC "state" is a signed, self-contained token rather than a value
  # stashed in the session. The LTI 1.3 launch returns via a cross-site POST,
  # which a SameSite cookie would not survive; keeping the round-trip data in
  # the signed state avoids weakening the session cookie. The signature is the
  # CSRF protection: only this tool can mint a valid state.
  LTI_STATE_PURPOSE = "lti.launch.state"
  LTI_STATE_TTL = 5.minutes

  before_action :set_group_and_assignment, only: %i[launch]
  before_action :set_lti_params, only: %i[launch]
  after_action :allow_iframe_lti, only: %i[launch]
  skip_before_action :authenticate_user!, only: %i[launch oidc_login jwks tool_config],
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
    state = lti_state_verifier.generate(
      { "nonce" => nonce, "deployment_id" => deployment.id },
      purpose: LTI_STATE_PURPOSE,
      expires_in: LTI_STATE_TTL
    )

    redirect_to build_oidc_redirect(deployment, nonce, state),
                allow_other_host: true
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Unknown LTI platform" }, status: :not_found
  end

  def jwks
    render json: { keys: [Lti::KeyManager.jwk] }
  end

  def tool_config
    base = request.base_url
    render json: {
      title: "CircuitVerse",
      description: "Digital circuit simulator for education",
      oidc_initiation_url: "#{base}/lti/login",
      target_link_uri: "#{base}/lti/launch",
      scopes: [],
      extensions: [
        {
          domain: request.host_with_port,
          platform: "canvas.instructure.com",
          privacy_level: "public",
          settings: {
            text: "CircuitVerse",
            placements: [
              {
                placement: "course_navigation",
                message_type: "LtiResourceLinkRequest",
                target_link_uri: "#{base}/lti/launch"
              },
              {
                placement: "link_selection",
                message_type: "LtiResourceLinkRequest",
                target_link_uri: "#{base}/lti/launch"
              }
            ]
          }
        }
      ],
      public_jwk_url: "#{base}/lti/jwks"
    }
  end

  private

    # Signs/verifies the OIDC state with the app secret so the launch round-trip
    # needs no server-side session state and no SameSite=None cookie.
    def lti_state_verifier
      Rails.application.message_verifier(LTI_STATE_PURPOSE)
    end

    def verified_request?
      super || lti_request_verified_by_protocol?
    end

    def lti_request_verified_by_protocol?
      case action_name
      when "launch"
        (params[:id_token].present? && params[:state].present?) ||
          (params[:oauth_consumer_key].present? && params[:oauth_signature].present?)
      when "oidc_login"
        params[:iss].present? && params[:client_id].present? &&
          params[:login_hint].present? && params[:target_link_uri].present?
      else
        false
      end
    end

    def handle_lti_13_launch
      state_data = lti_state_verifier.verified(params[:state].to_s, purpose: LTI_STATE_PURPOSE)
      if state_data.blank?
        render json: { error: "Invalid or expired state" }, status: :unauthorized
        return
      end

      deployment = find_lti_13_deployment(params[:id_token])
      payload    = Lti::JwtValidator.validate!(
        params[:id_token],
        deployment: deployment,
        nonce: state_data["nonce"]
      )

      @user = find_or_create_user_from_lti13(payload, deployment)
      sign_in(@user)

      session[:is_lti] = true

      redirect_to root_path
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Unknown deployment" }, status: :not_found
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
      render json: { error: "Email already associated with another account" }, status: :conflict
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
        client_id: Array(payload["aud"]).first,
        deployment_id: payload[DEPLOYMENT_ID_CLAIM]
      )
    end

    # Identify the user by the validated, deployment-scoped LTI subject (sub)
    # rather than the self-asserted email claim, which is unverified and
    # spoofable. Email is only used when provisioning a new account.
    def find_or_create_user_from_lti13(payload, deployment)
      User.find_or_create_by!(provider: "lti", uid: "#{deployment.id}:#{payload['sub']}") do |u|
        u.email        = payload["email"]
        u.name         = payload["name"].presence || payload["email"]
        u.password     = SecureRandom.hex(16)
        u.confirmed_at = Time.zone.now
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
        prompt: "none",
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
