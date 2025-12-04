class AddBaseToVehicles < ActiveRecord::Migration[8.0]
  def change
    add_column :vehicles, :base, :string
  end
end
