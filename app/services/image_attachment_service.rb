class ImageAttachmentService
  require "open-uri"

  def initialize(vehicle, image_urls)
    @vehicle = vehicle
    @image_urls = image_urls
    @successful_count = 0
    @failed_count = 0
  end

  def call
    attach_images_from_urls
    {
      success: @successful_count,
      failed: @failed_count,
      message: build_message
    }
  end

  private

  def attach_images_from_urls
    @image_urls.each do |url|
      next if url.blank?

      begin
        download_and_attach_image(url)
        @successful_count += 1
      rescue => e
        Rails.logger.error "Failed to download image from #{url}: #{e.message}"
        @failed_count += 1
      end
    end
  end

  def download_and_attach_image(url)
    downloaded_image = URI.open(url)
    filename = generate_filename
    @vehicle.images.attach(io: downloaded_image, filename: filename)
  end

  def generate_filename
    manufacturer = @vehicle.manufacturer.name.gsub(/[^0-9A-Za-z]/, "_")
    name = @vehicle.name.gsub(/[^0-9A-Za-z]/, "_")
    random = SecureRandom.hex(4)
    "#{manufacturer}_#{name}_#{random}.jpg"
  end

  def build_message
    if @successful_count > 0 && @failed_count == 0
      "#{@successful_count} #{'image'.pluralize(@successful_count)} downloaded and attached successfully!"
    elsif @successful_count > 0 && @failed_count > 0
      "#{@successful_count} #{'image'.pluralize(@successful_count)} attached, #{@failed_count} failed to download."
    else
      "Failed to download images. Please try again."
    end
  end
end
