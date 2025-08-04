class CreateVideos < ActiveRecord::Migration[7.1]
  def change
    create_table :videos do |t|
      t.references :place, null: false, foreign_key: true
      t.string :youtube_url
      t.string :title
      t.string :thumbnail_url

      t.timestamps
    end
  end
end
