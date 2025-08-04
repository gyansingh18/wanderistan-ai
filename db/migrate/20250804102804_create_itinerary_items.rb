class CreateItineraryItems < ActiveRecord::Migration[7.1]
  def change
    create_table :itinerary_items do |t|
      t.references :trip, null: false, foreign_key: true
      t.integer :day
      t.string :title
      t.text :description
      t.references :place, null: true, foreign_key: true

      t.timestamps
    end
  end
end
