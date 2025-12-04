module Api
  module V1
    module Toon
      class ManufacturersController < ApplicationController
        include ToonFormatter
        skip_before_action :verify_authenticity_token

        def index
          manufacturers = Manufacturer.all
          keys = %w[id name]

          toon_data = format_toon_array(manufacturers, keys, 'manufacturers')

          render plain: toon_data, content_type: 'text/toon'
        end

        def show
          manufacturer = Manufacturer.find(params[:id])
          keys = %w[id name]

          toon_data = format_toon_object(manufacturer, keys)

          render plain: toon_data, content_type: 'text/toon'
        rescue ActiveRecord::RecordNotFound
          render plain: "error: Manufacturer not found", status: :not_found, content_type: 'text/toon'
        end
      end
    end
  end
end
