class LtiController < ApplicationController
  before_action :set_group, only: %i[launch]
  before_action :set_lti_params, only: %i[launch]
  after_action :allow_iframe, only: %i[launch]
  
  def launch
    session[:isLTI]=true # the lti session starting
    require 'oauth/request_proxy/action_controller_request'
    
    if @group.present? # if there is a valid group based for the lti_token_key
      @provider = IMS::LTI::ToolProvider.new(
        params[:oauth_consumer_key], # lms_oauth_consumer_key
        @group.lti_token, # the group's lti_token
        params
      )

      if not @provider.valid_request?(request) # checking the lti request from the lms end
        render :launch_error, status: 401
        return
      end

      @@launch_params=params;
      user = User.find_by(email: @email_from_lms) # find user by matching email with circuitverse and lms 

      if user.present? # user is present in cv
        sign_in(user) # passwordless sign_in the user as the authenticity is verified via lms
        user_in_group = GroupMember.find_by(user_id:user.id,group_id:@group.id) # check if the user belongs to the cv group requested in the lti_request

        if user_in_group.present? || user.id === @group.mentor_id # user is a member or mentor of the group then allow authentication
          lms_auth_success_notice = 'Logged in as '+@email_from_lms+' via '+@lms_type+' for course '+@course_title_from_lms
          redirect_to group_path(@group), notice: lms_auth_success_notice # if auth_success send to group page
        else # if the user is not a member of the group then add the user
          user.group_members.create!(group: @group) # add the user to the group requested in the lti request
          lms_after_group_addition_notice = "You have been successfully added to the "+@group.name+" group."
          redirect_to group_path(@group), notice: lms_after_group_addition_notice
          return
        end
      else # if there is no such user in circuitverse, then show a notice to create an account in cv
        flash[:notice] = "You have no account associated with email "+@email_from_lms+", please create first and try again."
        render :launch_error, status: 401 
        return
      end
    else # if there is no valid group present for the lti_token_key
      flash[:notice] = "There is no group in CircuitVerse associated with your current LMS, Please ask your LMS Admin/Teacher to create one"
      render :launch_error, status: 401
      return
    end
  end

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end

  private
    def set_group # query db and check lms_oauth_consumer_key is equal to group where @group.lti_token_key == moodle_key
      @group = Group.find_by(lti_token_key: params[:oauth_consumer_key])
    end
    
    def set_lti_params # get some of the parameters from the lti request
      @email_from_lms = params[:lis_person_contact_email_primary] # the email from the LMS
      @lms_type = params[:tool_consumer_info_product_family_code] # type of lms like moodle/canvas
      @course_title_from_lms = params[:context_title] # the course titile from lms
    end
end
