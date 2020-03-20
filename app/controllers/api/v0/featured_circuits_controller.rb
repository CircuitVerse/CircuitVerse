class Api::V0::FeaturedCircuitsController < Api::V0::BaseController

  before_action :set_project, only:[:show]
  before_action :authorize_request, except: [:index]
  before_action :set_options

  def index
    @featured_circuits = FeaturedCircuit.all
    render :json => FeaturedCircuitSerializer.new(@featured_circuits, @options).serialized_json
  end

  def show
    if @featured_circuit.exists?
      render :json => FeaturedCircuitSerializer.new(@pfeatured_circuit, @options).serialized_json
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  private

  def set_project
    @featured_circuit = FeaturedCircuit.find(params[:id])
  end

  def set_options
    @options = {}
    @options[:include] = [:project]
  end

end

