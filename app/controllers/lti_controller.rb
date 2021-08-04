class LtiController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :launch # for lti integration
  before_action :set_group_assignment, only: %i[launch]
  before_action :set_lti_params, only: %i[launch]
  after_action :allow_iframe_lti, only: %i[launch]
  
  def launch
    session[:is_lti]=true # the lti session starting
    require 'oauth/request_proxy/action_controller_request'

    if @assignment.blank?
      # if no assignment is found
      flash[:notice] = t("lti.launch.notice_no_assignment")
      render :launch_error, status: 401
      return
    end
    
    if @group.present? # if there is a valid group based for the lti_token_key
      @provider = IMS::LTI::ToolProvider.new(
        params[:oauth_consumer_key], # lms_oauth_consumer_key
        @assignment.lti_shared_secret, # the group's lti_token
        params
      )

      if !@provider.valid_request?(request) # checking the lti request from the lms end
        render :launch_error, status: 401
        return
      end

      lms_lti_host = URI.join @launch_url_from_lms, '/' # identifies the domain and saves in session
      session[:lms_domain]=lms_lti_host

      @user = User.find_by(email: @email_from_lms) # find user by matching email with circuitverse and lms 

      if @user.present? # user is present in cv 
        if @user.id == @group.mentor_id # user is teacher
          sign_in(@user) # passwordless sign_in the user as the authenticity is verified via lms
          lms_auth_success_notice = t("lti.launch.notice_lms_auth_success_teacher", email_from_lms: @email_from_lms, lms_type: @lms_type, course_title_from_lms: @course_title_from_lms)
          redirect_to group_assignment_path(@group, @assignment), notice: lms_auth_success_notice # if auth_success send to group page
        else
          user_in_group = GroupMember.find_by(user_id:@user.id,group_id:@group.id) # check if the user belongs to the cv group

          if user_in_group.present? # user is member of the group
            # render the button
            flash[:notice] =  t("lti.launch.notice_students_open_in_cv")
            create_project_if_student_present() # create project with lis_result_sourced_id for the student
            render :open_incv, status: 200

          else # user is not a member of the group
            # send the user an email
            flash[:notice] = t("lti.launch.notice_ask_teacher")
            render :launch_error, status: 401
          end 
        end
      else # no such user in circuitverse,showing a notice to create an account in cv
        flash[:notice] = t("lti.launch.notice_no_account_in_cv", email_from_lms: @email_from_lms )
        render :launch_error, status: 400
      end
    else # there is no valid group present for the lti_consumer_key
      flash[:notice] = t("lti.launch.notice_invalid_group")
      render :launch_error, status: 400
    end
  end

  def allow_iframe_lti
    return unless session[:is_lti]
    
    response.headers["X-FRAME-OPTIONS"] = "ALLOW-FROM #{session[:lms_domain]}"
  end

  def create_project_if_student_present
    @user = User.find_by(email: @email_from_lms)
    @project = Project.find_by(author_id: @user.id, assignment_id: @assignment.id) # find if the project is already present
    if @project.blank? # if not then create one
      @project = @user.projects.new
      @project.name = "#{@user.name}/#{@assignment.name}"
      @project.assignment_id = @assignment.id
      @project.project_access_type = "Private"
      @project.build_project_datum
      @project.lis_result_sourced_id = params[:lis_result_sourcedid] # this param is required for grade submission
      @project.save
    end
  end

  private

    def set_group_assignment # query db and check lms_oauth_consumer_key is equal to which assignment and find the group also
      @assignment = Assignment.find_by(lti_consumer_key: params[:oauth_consumer_key])
      if @assignment.present?
        @group =@assignment.group
      end
    end
    
    def set_lti_params # get some of the parameters from the lti request
      @email_from_lms = params[:lis_person_contact_email_primary] # the email from the LMS
      @lms_type = params[:tool_consumer_info_product_family_code] # type of lms like moodle/canvas
      @course_title_from_lms = params[:context_title] # the course titile from lms
      @launch_url_from_lms = params[:launch_presentation_return_url]
      session[:lis_outcome_service_url] = params[:lis_outcome_service_url] # requires for grade submission
      session[:oauth_consumer_key] = params[:oauth_consumer_key] # requires for grade submission
    end
end
