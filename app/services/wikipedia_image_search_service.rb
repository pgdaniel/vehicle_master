class WikipediaImageSearchService
  include HTTParty
  base_uri "https://en.wikipedia.org/w/api.php"

  def initialize(search_query)
    @search_query = search_query
    @image_results = []
  end

  def call
    search_wikipedia_articles
    @image_results.uniq.first(12)
  end

  private

  def search_wikipedia_articles
    response = self.class.get("", query: {
      action: "query",
      list: "search",
      srsearch: @search_query,
      format: "json"
    })

    if response.success?
      page_titles = response.dig("query", "search")&.first(3)&.map { |result| result["title"] } || []
      fetch_images_from_pages(page_titles)
    end
  rescue => e
    Rails.logger.error "Wikipedia article search failed: #{e.message}"
  end

  def fetch_images_from_pages(page_titles)
    page_titles.each do |title|
      break if @image_results.length >= 12

      response = self.class.get("", query: {
        action: "query",
        titles: title,
        prop: "images",
        format: "json"
      })

      if response.success?
        pages = response.dig("query", "pages") || {}

        pages.each do |page_id, page_data|
          image_titles = page_data.dig("images")&.first(10)&.map { |img| img["title"] } || []
          fetch_image_urls(image_titles)
          break if @image_results.length >= 12
        end
      end
    end
  rescue => e
    Rails.logger.error "Wikipedia image fetch failed: #{e.message}"
  end

  def fetch_image_urls(image_titles)
    image_titles.each do |img_title|
      break if @image_results.length >= 12

      # Skip non-photo files (logos, icons, svg files)
      next if img_title.match?(/\.svg$/i) || img_title.match?(/logo/i) || img_title.match?(/icon/i)

      response = self.class.get("", query: {
        action: "query",
        titles: img_title,
        prop: "imageinfo",
        iiprop: "url",
        format: "json"
      })

      if response.success?
        pages = response.dig("query", "pages") || {}

        pages.each do |img_page_id, img_page_data|
          image_url = img_page_data.dig("imageinfo", 0, "url")
          @image_results << image_url if image_url
        end
      end
    end
  rescue => e
    Rails.logger.error "Wikipedia image URL fetch failed: #{e.message}"
  end
end
