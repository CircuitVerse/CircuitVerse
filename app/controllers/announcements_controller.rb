# frozen_string_literal: true

class AnnouncementsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin
  before_action :set_announcement, only: %i[edit update show ]

  def index
    @announcements = Announcement.all
    @user = current_user
  end

  def show
    @announcement = Announcement.find(params[:id])
    @user = current_user
  end

  def new
    @announcement = Announcement.new
  end

  def create
    @announcement = Announcement.new(announcement_params)
    if @announcement.save
      redirect_to "/"
    else
      render "new"
    end
  end

  def edit
    @announcement = Announcement.find(params[:id])
  end

  def update
    @announcement = Announcement.find(params[:id])
    if @announcement.update(announcement_params)
      redirect_to @announcement
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

    def announcement_params
      params.require(:announcement).permit(:body, :start_time, :end_time)
    end
end
