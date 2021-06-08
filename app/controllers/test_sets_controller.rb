# frozen_string_literal: true

class TestSetsController < ApplicationController
  before_action :set_test_set, only: %i[]

  before_action :check_access, only: %i[]

  # GET /testbench
  def new
    @test_set = TestSet.new
  end

  # POST /testbench/create
  def create
    @test_set = current_user.test_sets.create(test_set_params)

    respond_to do |format|
      if @test_set.save
        format.html { redirect_to "/testbench", notice: "Test Set was successfully created." }
        format.json { render :show, status: :created, location: @test_set }
      else
        format.html { render :new }
        format.json { render json: @test_set.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    def test_set_params
      params.require(:test_set).permit(:title, :testset_access_type, :description, :data)
    end

    def set_test_set

    end

    def check_access
      authorize @test_set, :show_access?
    end

end
