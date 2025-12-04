module Filterable
  extend ActiveSupport::Concern

  private

  def apply_filters(relation, model_class)
    model_class.column_names.each do |column|
      next if %w[id created_at updated_at manufacturer_id].include?(column)
      
      if params[column].present?
        relation = apply_column_filter(relation, column, params[column])
      end
    end

    # Special handling for manufacturer_name
    if params[:manufacturer_name].present?
      relation = relation.joins(:manufacturer).where(manufacturers: { name: params[:manufacturer_name] })
    end

    relation
  end

  def apply_column_filter(relation, column, value)
    case column
    when 'name'
      relation.where("vehicles.#{column} LIKE ?", "%#{value}%")
    when 'guzzler', 'turbo_charger', 'super_charger'
      # Only accept true/false strings for boolean
      if %w[true false].include?(value.downcase)
        relation.where(column => value.downcase == 'true')
      else
        relation
      end
    when 'year', 'cylinders'
      # Only accept valid integers
      if value.match?(/^\d+$/)
        relation.where(column => value.to_i)
      else
        relation
      end
    when 'displacement_liters'
      # Only accept valid numbers (int or float)
      if value.match?(/^\d+(\.\d+)?$/)
        relation.where(column => value.to_f)
      else
        relation
      end
    else
      relation.where(column => value)
    end
  end
end