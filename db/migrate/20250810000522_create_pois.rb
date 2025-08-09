class CreatePois < ActiveRecord::Migration[7.1]
  def change
    create_table :pois do |t|
      t.string :name, null: false
      t.string :poi_type, null: false
      t.decimal :latitude, precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false
      t.text :description
      t.decimal :price
      t.decimal :rating
      t.json :amenities
      t.json :opening_hours
      t.string :contact_info
      t.string :website
      t.boolean :verified, default: false
      t.integer :likes_count, default: 0
      t.integer :reviews_count, default: 0

      t.timestamps
    end

    add_index :pois, [:latitude, :longitude]
    add_index :pois, :poi_type
    add_index :pois, :verified
  end
end
