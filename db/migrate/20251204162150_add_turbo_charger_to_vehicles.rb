class AddTurboChargerToVehicles < ActiveRecord::Migration[8.0]
  def change
    add_column :vehicles, :turbo_charger, :boolean
  end
end
