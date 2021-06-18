class LtiController < ApplicationController
  before_action :set_group_assignment, only: %i[launch]
  before_action :set_lti_params, only: %i[launch]
  after_action :allow_iframe, only: %i[launch]
  
  def launch
    session[:isLTI]=true # the lti session starting
    require 'oauth/request_proxy/action_controller_request'

    if !@assignment.present?
      # if no assignment is found
      flash[:notice] = "No such Assignment is present in CircuitVerse, please contact your LMS Administrator/Teacher"
      render :launch_error, status: 401
      return
    end
    
    if @group.present? # if there is a valid group based for the lti_token_key
      @provider = IMS::LTI::ToolProvider.new(
        params[:oauth_consumer_key], # lms_oauth_consumer_key
        @assignment.lti_shared_secret, # the group's lti_token
        params
      )

      if not @provider.valid_request?(request) # checking the lti request from the lms end
        render :launch_error, status: 401
        return
      end

      @@launch_params=params;
      @user = User.find_by(email: @email_from_lms) # find user by matching email with circuitverse and lms 

      if @user.present? # user is present in cv 
        if @user.id === @group.mentor_id # user is teacher
          sign_in(@user) # passwordless sign_in the user as the authenticity is verified via lms
          lms_auth_success_notice = 'Logged in as '+@email_from_lms+' via '+@lms_type+' for course '+@course_title_from_lms
          redirect_to group_assignment_path(@group,@assignment), notice: lms_auth_success_notice # if auth_success send to group page
        else
          user_in_group = GroupMember.find_by(user_id:@user.id,group_id:@group.id) # check if the user belongs to the cv group

          if user_in_group.present? # user is member of the group
            # render the button
            flash[:notice] = "Please open the Assigment in CircuitVerse"
            render :open_incv

          else # user is not a member of the group
            # send the user an email
            flash[:notice] = "Check your email for a group invitation from "+@group.name+" group, first join the group then try again."
            render :launch_error, status: 401
          end 
        end
      else # no such user in circuitverse,showing a notice to create an account in cv
        flash[:notice] = "You have no account associated with email "+@email_from_lms+", please create first and try again."
        render :launch_error, status: 400
      end
    else # there is no valid group present for the lti_consumer_key
      flash[:notice] = "There is no group in CircuitVerse associated with your current LMS, Please ask your LMS Admin/Teacher to create one"
      render :launch_error, status: 400
    end
  end

  def allow_iframe
    if session[:isLTI]
      response.headers.except! "X-Frame-Options"
    end
  end

  private

    def set_group_assignment # query db and check lms_oauth_consumer_key is equal to which assignment and find the group also
      @assignment = Assignment.find_by(lti_consumer_key: params[:oauth_consumer_key])
      if @assignment.present?
        @group = Group.find_by(id: @assignment.group_id)
      end
    end
    
    def set_lti_params # get some of the parameters from the lti request
      @email_from_lms = params[:lis_person_contact_email_primary] # the email from the LMS
      @lms_type = params[:tool_consumer_info_product_family_code] # type of lms like moodle/canvas
      @course_title_from_lms = params[:context_title] # the course titile from lms
    end
end
