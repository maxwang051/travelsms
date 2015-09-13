class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.float :latitude
      t.float :longitude
      t.string :phone_number
      t.string :location

      t.timestamps null: false
    end
  end
end
