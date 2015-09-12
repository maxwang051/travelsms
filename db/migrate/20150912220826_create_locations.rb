class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
    	t.float :latitude, :longitude

      t.timestamps null: false
    end
  end
end
