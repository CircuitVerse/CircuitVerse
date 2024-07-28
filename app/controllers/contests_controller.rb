# frozen_string_literal: true

class ContestsController < ApplicationController
  # before_action :authorize_admin, only: %i[admin]

  # GET /contests
  def index
    @contests = Contest.all
  end
  
  def show
    @contest = Contest.find(params[:id])
    @submissions = @contest.submissions
    @user_count = User.count
  end
  
  def admin
    @contests = Contest.all
  end

  # POST /contest/create
  def create
    @contest = Contest.new
    @contest.deadline = 1.month.from_now
    @contest.status = "Live"
    respond_to do |format|
      if @contest.save
        format.html { redirect_to contest_page_path(@contest.id), notice: "Contest was successfully started." }
        format.json { render :show, status: :created, location: @contest }
      else
        format.html { render :admin }
        format.json { render json: @contest.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def authorize_admin
    authorize Announcement.new, :admin?
  end
end