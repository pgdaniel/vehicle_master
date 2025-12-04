require_relative "../config/environment"

require "csv"

CSV.foreach("vehicles.csv", headers: true) do |row|
  manufacturer = Manufacturer.find_or_create_by!(name: row["make"])
  manufacturer.vehicles.find_or_create_by!(
    name: row["model"],
    year: row["year"],
    displacement_liters: row["displ"],
    transmission: row["trany"],
    cylinders: row["cylinders"],
    klass: row["VClass"]
  )
end
