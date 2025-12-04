module Api
  module V1
    class ManufacturersController < ApplicationController
      skip_before_action :verify_authenticity_token

      def index
        manufacturers = Manufacturer.all
        render json: manufacturers
      end

      def show
        manufacturer = Manufacturer.find(params[:id])
        render json: manufacturer
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Manufacturer not found' }, status: :not_found
      end
    end
  end
end
