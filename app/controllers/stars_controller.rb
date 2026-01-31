# frozen_string_literal: true

class StarsController < ApplicationController
  before_action :set_star, only: %i[destroy]
  before_action :authenticate_user!, only: %i[destroy create]
  # GET /stars
  # GET /stars.json
  # def index
  #   @stars = Star.all
  # end

  # GET /stars/1
  # GET /stars/1.json
  # def show
  # end

  # GET /stars/new
  # def new
  #   @star = Star.new
  # end

  # GET /stars/1/edit
  # def edit
  # end

  # POST /stars
  # POST /stars.json
  def create
    @star = Star.new(star_params)
    Rails.logger.info "IDOR_DEBUG: Params: #{star_params.inspect}"
    Rails.logger.info "IDOR_DEBUG: Current User: #{current_user&.id}"
    @star.user_id = current_user.id  # SECURITY FIX: Force authenticated user's ID
    if @star.save
      Rails.logger.info "IDOR_DEBUG: Star saved for user #{@star.user_id}"
      render plain: "Star added!"
    else
      render plain: "Failed to add star", status: :unprocessable_entity
    end
  end

  # PATCH/PUT /stars/1
  # PATCH/PUT /stars/1.json
  # def update
  #   respond_to do |format|
  #     if @star.update(star_params)
  #       format.html { redirect_to @star, notice: 'Star was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @star }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @star.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /stars/1
  # DELETE /stars/1.json
  def destroy
    @star.destroy
    render plain: "Star removed!"
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    # SECURITY FIX: Only allow users to manage their own stars
    def set_star
      @star = current_user.stars.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render plain: "Star not found or access denied", status: :not_found
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    # SECURITY FIX: Removed user_id from permitted params
    def star_params
      params.expect(star: [:project_id])
    end
end
