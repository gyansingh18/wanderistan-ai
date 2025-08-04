class CreateTrips < ActiveRecord::Migration[7.1]
  def change
    create_table :trips do |t|
      t.string :title
      t.string :destination
      t.date :start_date
      t.date :end_date
      t.decimal :budget
      t.references :user, null: false, foreign_key: true
      t.text :ai_summary
      t.text :itinerary

      t.timestamps
    end
  end
end
