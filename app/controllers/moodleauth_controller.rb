
class MoodleauthController < ApplicationController
    before_action :authenticate_user!
    before_action :check_grantaccess_and_redirect
    


    def moodlegrantedpermissionupdate
        #ToDo: After User.update(isMoodleGranted:true) => redirect_to "/groups/"+params[:group_id]

    end


    private

        def check_grantaccess_and_redirect
            @group = Group.find(params[:group_id])
            @isMoodleGranted = current_user.isMoodleGranted
            # implement the redirect logic here if @isMoodleGranted == true then redirect to view
            if @isMoodleGranted == true
                ## go to the group view page
                redirect_to "/groups/"+params[:group_id]
                
            end

        end
end
