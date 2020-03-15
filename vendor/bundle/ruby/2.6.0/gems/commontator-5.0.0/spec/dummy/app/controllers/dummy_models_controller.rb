class DummyModelsController < ApplicationController
  before_action :get_dummy

  def show
    commontator_thread_show(@dummy_model)
  end

  def hide
    render :show
  end

  def url_options
    return Hash.new if request.nil?
    super
  end

  protected

  def get_dummy
    @dummy_model = DummyModel.find(params[:id])
  end
end

