# frozen_string_literal: true

class ContestsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  # before_action :authorize_admin, only: %i[admin]

  # GET /contests
  def index
    @contests = Contest.all.order(id: :desc)
  end

  # GET /contests/:id
  def show
    @contest = Contest.find(params[:id])
    @submissions = @contest.submissions
    @user_count = User.count
  end

  # GET /contests/admin
  def admin
    @contests = Contest.all.order(id: :desc)
  end

  def close_contest
    @contest = Contest.find(params[:id])
    @contest.deadline = Time.zone.now
    @contest.status = "Completed"
    respond_to do |format|
      if @contest.save
        format.html { redirect_to contest_page_path(@contest.id), notice: "Contest was successfully ended." }
        format.json { render :show, status: :created, location: @contest }
      else
        format.html { render :admin }
        format.json { render json: @contest.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /contest/create
  def create
    # checking for any other live contest, if found mark is as completed
    Contest.all.each do |contest|
      if contest.status == "Live"
        contest.status = "Completed"
        contest.deadline = Time.zone.now
        contest.save
      end
    end
    @contest = Contest.new
    @contest.deadline = 1.month.from_now
    @contest.status = "Live"
    respond_to do |format|
      if @contest.save
        ContestNotification.with(contest: @contest).deliver_later(User.all)
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