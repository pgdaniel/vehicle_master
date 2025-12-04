class AddSuperChargerToVehicles < ActiveRecord::Migration[8.0]
  def change
    add_column :vehicles, :super_charger, :boolean
  end
end
