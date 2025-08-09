# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_08_10_000522) do
  create_table "itinerary_items", force: :cascade do |t|
    t.integer "trip_id", null: false
    t.integer "day"
    t.string "title"
    t.text "description"
    t.integer "place_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["place_id"], name: "index_itinerary_items_on_place_id"
    t.index ["trip_id"], name: "index_itinerary_items_on_trip_id"
  end

  create_table "places", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.decimal "latitude"
    t.decimal "longitude"
    t.string "region"
    t.string "category"
    t.string "cover_image_url"
    t.boolean "featured"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pois", force: :cascade do |t|
    t.string "name", null: false
    t.string "poi_type", null: false
    t.decimal "latitude", precision: 10, scale: 6, null: false
    t.decimal "longitude", precision: 10, scale: 6, null: false
    t.text "description"
    t.decimal "price"
    t.decimal "rating"
    t.json "amenities"
    t.json "opening_hours"
    t.string "contact_info"
    t.string "website"
    t.boolean "verified", default: false
    t.integer "likes_count", default: 0
    t.integer "reviews_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["latitude", "longitude"], name: "index_pois_on_latitude_and_longitude"
    t.index ["poi_type"], name: "index_pois_on_poi_type"
    t.index ["verified"], name: "index_pois_on_verified"
  end



  create_table "trips", force: :cascade do |t|
    t.string "title"
    t.string "destination"
    t.date "start_date"
    t.date "end_date"
    t.decimal "budget"
    t.integer "user_id", null: false
    t.text "ai_summary"
    t.text "itinerary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "budget_estimate"
    t.json "budget_breakdown"
    t.json "money_saving_tips"
    t.index ["user_id"], name: "index_trips_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "videos", force: :cascade do |t|
    t.integer "place_id", null: false
    t.string "youtube_url"
    t.string "title"
    t.string "thumbnail_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["place_id"], name: "index_videos_on_place_id"
  end

  add_foreign_key "itinerary_items", "places"
  add_foreign_key "itinerary_items", "trips"

  add_foreign_key "trips", "users"
  add_foreign_key "videos", "places"
end
