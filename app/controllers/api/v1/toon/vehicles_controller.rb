require 'ostruct'

module Api
  module V1
    module Toon
      class VehiclesController < ApplicationController
        include Filterable
        include ToonFormatter
        skip_before_action :verify_authenticity_token

        def index
          # Pagination parameters with defaults
          page = (params[:page] || 1).to_i
          per_page = (params[:per_page] || 100).to_i
          per_page = [[per_page, 1].max, 1000].min # Clamp between 1 and 1000

          # Count query - separate from data query to avoid relation pollution
          count_query = Vehicle.joins(:manufacturer)
          count_query = apply_filters(count_query, Vehicle)
          total_count = count_query.distinct.count('vehicles.id')

          # Data query - build fresh to avoid any mutation issues
          data_query = Vehicle.joins(:manufacturer)
          data_query = apply_filters(data_query, Vehicle)
          data_query = data_query
            .select('vehicles.*', 'manufacturers.name as manufacturer_name')
            .offset((page - 1) * per_page)
            .limit(per_page)

          keys = %w[id year displacement_liters transmission cylinders klass manufacturer_id name guzzler base turbo_charger super_charger manufacturer_name]

          toon_data = format_toon_array(
            data_query,
            keys,
            'vehicles',
            pagination: { page: page, per_page: per_page, total_count: total_count }
          )

          render plain: toon_data, content_type: 'text/toon'
        end

        def show
          vehicle = Vehicle.includes(:manufacturer).find(params[:id])

          keys = %w[id year displacement_liters transmission cylinders klass manufacturer_id name guzzler base turbo_charger super_charger manufacturer_name]

          vehicle_data = OpenStruct.new(
            id: vehicle.id,
            year: vehicle.year,
            displacement_liters: vehicle.displacement_liters,
            transmission: vehicle.transmission,
            cylinders: vehicle.cylinders,
            klass: vehicle.klass,
            manufacturer_id: vehicle.manufacturer_id,
            name: vehicle.name,
            guzzler: vehicle.guzzler,
            base: vehicle.base,
            turbo_charger: vehicle.turbo_charger,
            super_charger: vehicle.super_charger,
            manufacturer_name: vehicle.manufacturer.name
          )

          toon_data = format_toon_object(vehicle_data, keys)

          render plain: toon_data, content_type: 'text/toon'
        rescue ActiveRecord::RecordNotFound
          render plain: "error: Vehicle not found", status: :not_found, content_type: 'text/toon'
        end
      end
    end
  end
end
