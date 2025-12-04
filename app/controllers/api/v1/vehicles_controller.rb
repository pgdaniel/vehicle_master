module Api
  module V1
    class VehiclesController < ApplicationController
      include Filterable
      skip_before_action :verify_authenticity_token

      def index
        vehicles = Vehicle.includes(:manufacturer)
        vehicles = apply_filters(vehicles, Vehicle)

        vehicles_data = vehicles.map do |vehicle|
          vehicle.as_json(except: [:created_at, :updated_at])
            .merge(manufacturer_name: vehicle.manufacturer.name)
        end

        render json: vehicles_data
      end

      def show
        vehicle = Vehicle.includes(:manufacturer).find(params[:id])
        vehicle_data = vehicle.as_json(except: [:created_at, :updated_at])
          .merge(manufacturer_name: vehicle.manufacturer.name)

        render json: vehicle_data
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Vehicle not found' }, status: :not_found
      end
    end
  end
end
