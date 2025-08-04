class CreatePlaces < ActiveRecord::Migration[7.1]
  def change
    create_table :places do |t|
      t.string :name
      t.text :description
      t.decimal :latitude
      t.decimal :longitude
      t.string :region
      t.string :category
      t.string :cover_image_url
      t.boolean :featured

      t.timestamps
    end
  end
end
