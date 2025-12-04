class AddGuzzlerToVehicles < ActiveRecord::Migration[8.0]
  def change
    add_column :vehicles, :guzzler, :boolean
  end
end
