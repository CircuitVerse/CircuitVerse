# frozen_string_literal: true

class StarsController < ApplicationController
  before_action :authenticate_user!, only: %i[destroy create]
  before_action :set_star, only: %i[destroy]
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
    @star = current_user.stars.build(star_params)
    if @star.save
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

    def set_star
      @star = current_user.stars.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def star_params
      params.expect(star: [:project_id])
    end
end
