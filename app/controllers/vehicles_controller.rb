class VehiclesController < ApplicationController
  include Filterable

  def index
    vehicles = Vehicle.includes(:manufacturer)
    vehicles = apply_filters(vehicles, Vehicle)
    @pagy, @vehicles = pagy(vehicles, limit: 50)
  end

  def show
    @vehicle = Vehicle.includes(:manufacturer).with_attached_images.find(params[:id])
  end

  def attach_images
    @vehicle = Vehicle.find(params[:id])

    if params[:images].present?
      params[:images].each do |image|
        @vehicle.images.attach(image)
      end
      redirect_to @vehicle, notice: "Images uploaded successfully!"
    else
      redirect_to @vehicle, alert: "Please select at least one image."
    end
  end

  def delete_image
    @vehicle = Vehicle.find(params[:id])
    image = @vehicle.images.find(params[:image_id])
    image.purge
    redirect_to @vehicle, notice: "Image deleted successfully!"
  end

  def search_images
    @vehicle = Vehicle.includes(:manufacturer).find(params[:id])

    # Search query based on vehicle details
    search_query = "#{@vehicle.year} #{@vehicle.manufacturer.name} #{@vehicle.name}"

    # Use the Wikipedia image search service
    @image_results = WikipediaImageSearchService.new(search_query).call

    # Fallback: Generate some sample image URLs for testing if no results
    if @image_results.empty?
      @image_results = [
        "https://via.placeholder.com/400x300.png?text=#{CGI.escape(search_query)}+No+Images+Found"
      ]
    end
  end

  def attach_selected_images
    @vehicle = Vehicle.find(params[:id])

    if params[:selected_image_urls].present?
      result = ImageAttachmentService.new(@vehicle, params[:selected_image_urls]).call

      if result[:success] > 0
        redirect_to @vehicle, notice: result[:message]
      else
        redirect_to search_images_vehicle_path(@vehicle), alert: result[:message]
      end
    else
      redirect_to search_images_vehicle_path(@vehicle), alert: "Please select at least one image."
    end
  end
end
