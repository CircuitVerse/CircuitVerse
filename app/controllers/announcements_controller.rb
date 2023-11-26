# frozen_string_literal: true

class AnnouncementsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin

  def index
    # @type [Array<Announcement>]
    @announcements = Announcement.all
    # @type [User]
    @user = current_user
  end

  def new
    @announcement = Announcement.new
  end

  def edit
    @announcement = Announcement.find(params[:id])
  end

  def create
    @announcement = Announcement.new(announcement_params)
    if @announcement.save
      redirect_to "/announcements"
    else
      render "new"
    end
  end

  def update
    @announcement = Announcement.find(params[:id])
    if @announcement.update(announcement_params)
      redirect_to "/announcements"
    else
      render "edit"
    end
  end

  def destroy
    @announcement = Announcement.find(params[:id])
    @announcement.destroy
    redirect_to announcements_path
  end

  private

    def authorize_admin
      authorize Announcement.new, :admin?
    end

    # Only allow a list of trusted parameters through.
    # @return [ActionController::Parameters]
    def announcement_params
      params.require(:announcement).permit(:body, :link, :start_date, :end_date)
    end
end
