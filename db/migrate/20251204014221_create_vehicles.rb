class CreateVehicles < ActiveRecord::Migration[8.0]
  def change
    create_table :vehicles do |t|
      t.integer :year
      t.float :displacement_liters
      t.string :transmission
      t.integer :cylinders
      t.string :klass
      t.belongs_to :manufacturer, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
