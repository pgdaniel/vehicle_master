module Api
  module V1
    class VehiclesController < ApplicationController
      include Filterable
      include Pagy::Backend
      skip_before_action :verify_authenticity_token

      def index
        vehicles = Vehicle.includes(:manufacturer, images_attachments: :blob)
        vehicles = apply_filters(vehicles, Vehicle)

        pagy, paginated_vehicles = pagy(vehicles, limit: params[:per_page] || 50)

        vehicles_data = paginated_vehicles.map do |vehicle|
          vehicle.as_json(except: [ :created_at, :updated_at ])
            .merge(
              manufacturer_name: vehicle.manufacturer.name,
              image_urls: vehicle.images.map { |image| Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true) }
            )
        end

        render json: {
          data: vehicles_data,
          pagination: {
            page: pagy.page,
            per_page: pagy.limit,
            total_count: pagy.count,
            total_pages: pagy.pages
          }
        }
      end

      def show
        vehicle = Vehicle.includes(:manufacturer, images_attachments: :blob).find(params[:id])
        vehicle_data = vehicle.as_json(except: [ :created_at, :updated_at ])
          .merge(
            manufacturer_name: vehicle.manufacturer.name,
            image_urls: vehicle.images.map { |image| Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true) }
          )

        render json: vehicle_data
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Vehicle not found" }, status: :not_found
      end
    end
  end
end
