require_relative "../config/environment"

require "csv"

CSV.foreach("vehicles.csv", headers: true) do |row|
  manufacturer = Manufacturer.find_or_create_by!(name: row["make"])

  # if row["model"] == "Mustang Dark Horse"
  #   binding.pry
  # end

  manufacturer.vehicles.find_or_create_by!(
    name: row["model"],
    base: row["baseModel"],
    year: row["year"],
    displacement_liters: row["displ"],
    transmission: row["trany"],
    cylinders: row["cylinders"],
    klass: row["VClass"],
    guzzler: row["guzzler"] ? true : false,
    turbo_charger: row["tCharger"] ? true : false,
    super_charger: row["sCharger"] ? true : false
  )
end
