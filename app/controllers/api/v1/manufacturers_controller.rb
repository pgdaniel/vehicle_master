module Api
  module V1
    class ManufacturersController < ApplicationController
      include Pagy::Backend
      skip_before_action :verify_authenticity_token

      def index
        pagy, manufacturers = pagy(Manufacturer.all, limit: params[:per_page] || 50)

        render json: {
          data: manufacturers,
          pagination: {
            page: pagy.page,
            per_page: pagy.limit,
            total_count: pagy.count,
            total_pages: pagy.pages
          }
        }
      end

      def show
        manufacturer = Manufacturer.find(params[:id])
        render json: manufacturer
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Manufacturer not found" }, status: :not_found
      end
    end
  end
end
