module ToonFormatter
  extend ActiveSupport::Concern

  private

  def format_toon_array(records, keys, array_name = nil, pagination: {})
    # Determine array name
    name = array_name || (records.respond_to?(:model_name) ? records.model_name.plural : 'items')

    # Use pagination total_count if available, otherwise count the records
    count = pagination[:total_count] || (records.is_a?(Array) ? records.count : records.count)

    # Header: arrayName[count]{key1,key2,key3}:
    result = "#{name}[#{count}]{#{keys.join(',')}}:\n"

    # Add pagination metadata if present
    if pagination[:page] && pagination[:per_page] && pagination[:total_count]
      total_pages = (pagination[:total_count].to_f / pagination[:per_page]).ceil
      result += "pagination{page,per_page,total_count,total_pages}:\n"
      result += "  #{pagination[:page]},#{pagination[:per_page]},#{pagination[:total_count]},#{total_pages}\n"
    end

    # Data rows
    records.each do |record|
      values = keys.map do |key|
        value = record.respond_to?(key) ? record.send(key) : record[key]
        format_toon_value(value)
      end
      result += "  #{values.join(',')}\n"
    end

    result
  end

  def format_toon_object(record, keys)
    result = ""
    keys.each do |key|
      value = record.respond_to?(key) ? record.send(key) : record[key]
      result += "#{key}: #{format_toon_value(value)}\n"
    end
    result
  end

  def format_toon_value(value)
    case value
    when String
      # Escape commas and newlines in strings
      value.include?(',') || value.include?("\n") ? "\"#{value.gsub('"', '\"')}\"" : value
    when TrueClass, FalseClass
      value.to_s
    when NilClass
      "null"
    when Numeric
      value.to_s
    when Time, DateTime, Date
      value.iso8601
    else
      value.to_s
    end
  end
end
