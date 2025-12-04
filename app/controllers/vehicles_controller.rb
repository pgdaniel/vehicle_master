class VehiclesController < ApplicationController
 def index
  render json: Vehicle.all, except: [:created_at, :updated_at]
 end
end
