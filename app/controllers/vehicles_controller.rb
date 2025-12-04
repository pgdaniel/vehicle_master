class VehiclesController < ApplicationController
  include Filterable

  def index
    vehicles = Vehicle.includes(:manufacturer)
    vehicles = apply_filters(vehicles, Vehicle)
    @pagy, @vehicles = pagy(vehicles, limit: 25)
  end

  def show
    @vehicle = Vehicle.includes(:manufacturer).find(params[:id])
  end
end
