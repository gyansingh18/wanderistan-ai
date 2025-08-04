# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create demo user
user = User.create!(
  email: 'demo@wanderistan.com',
  password: 'password123',
  password_confirmation: 'password123'
)

puts "Created demo user: #{user.email}"

# Create sample places
places_data = [
  {
    name: "Manali",
    description: "A beautiful hill station in Himachal Pradesh, known for its scenic beauty and adventure activities.",
    latitude: 32.2432,
    longitude: 77.1892,
    region: "Himalayas",
    category: "Mountain",
    cover_image_url: "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800",
    featured: true
  },
  {
    name: "Rishikesh",
    description: "The yoga capital of the world, famous for spiritual retreats and adventure sports.",
    latitude: 30.0869,
    longitude: 78.2676,
    region: "North India",
    category: "Adventure",
    cover_image_url: "https://images.unsplash.com/photo-1589308078059-be1415eab4c3?w=800",
    featured: true
  },
  {
    name: "Kerala Backwaters",
    description: "Serene backwaters with houseboat cruises and traditional Ayurvedic treatments.",
    latitude: 9.9312,
    longitude: 76.2673,
    region: "South India",
    category: "Beach",
    cover_image_url: "https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?w=800",
    featured: true
  },
  {
    name: "Taj Mahal",
    description: "The iconic white marble mausoleum, one of the Seven Wonders of the World.",
    latitude: 27.1751,
    longitude: 78.0421,
    region: "Central India",
    category: "Historical",
    cover_image_url: "https://images.unsplash.com/photo-1564507592333-c60657eea523?w=800",
    featured: true
  },
  {
    name: "Varanasi",
    description: "The spiritual capital of India, known for its ghats and religious significance.",
    latitude: 25.3176,
    longitude: 82.9739,
    region: "North India",
    category: "Cultural",
    cover_image_url: "https://images.unsplash.com/photo-1589308078059-be1415eab4c3?w=800",
    featured: false
  },
  {
    name: "Goa Beaches",
    description: "Famous for its pristine beaches, Portuguese architecture, and vibrant nightlife.",
    latitude: 15.2993,
    longitude: 74.1240,
    region: "Coastal",
    category: "Beach",
    cover_image_url: "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800",
    featured: true
  },
  {
    name: "Sikkim",
    description: "A peaceful state in the Himalayas known for its monasteries and mountain views.",
    latitude: 27.7172,
    longitude: 88.3958,
    region: "Himalayas",
    category: "Mountain",
    cover_image_url: "https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?w=800",
    featured: false
  },
  {
    name: "Jaipur",
    description: "The Pink City, famous for its palaces, forts, and rich cultural heritage.",
    latitude: 26.9124,
    longitude: 75.7873,
    region: "West India",
    category: "Cultural",
    cover_image_url: "https://images.unsplash.com/photo-1564507592333-c60657eea523?w=800",
    featured: false
  }
]

places = []
places_data.each do |place_data|
  place = Place.create!(place_data)
  places << place
  puts "Created place: #{place.name}"
end

# Create sample videos for places
videos_data = [
  {
    youtube_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    title: "Manali Travel Guide - Complete Tour",
    thumbnail_url: "https://img.youtube.com/vi/dQw4w9WgXcQ/mqdefault.jpg"
  },
  {
    youtube_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    title: "Rishikesh Adventure Activities",
    thumbnail_url: "https://img.youtube.com/vi/dQw4w9WgXcQ/mqdefault.jpg"
  },
  {
    youtube_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    title: "Kerala Backwaters Houseboat Experience",
    thumbnail_url: "https://img.youtube.com/vi/dQw4w9WgXcQ/mqdefault.jpg"
  }
]

places.each_with_index do |place, index|
  if videos_data[index]
    place.videos.create!(videos_data[index])
    puts "Added video to #{place.name}"
  end
end

# Create sample trips for demo user
trip1 = user.trips.create!(
  title: "Manali Adventure Trip",
  destination: "Manali",
  start_date: Date.current + 1.month,
  end_date: Date.current + 1.month + 5.days,
  budget: 25000,
  ai_summary: "A 5-day adventure trip to Manali with trekking, paragliding, and local sightseeing."
)

trip2 = user.trips.create!(
  title: "Kerala Wellness Retreat",
  destination: "Kerala",
  start_date: Date.current + 2.months,
  end_date: Date.current + 2.months + 7.days,
  budget: 35000,
  ai_summary: "A relaxing 7-day wellness retreat in Kerala with Ayurvedic treatments and backwater cruises."
)

puts "Created sample trips for demo user"

# Add places to trips
manali_place = Place.find_by(name: "Manali")
kerala_place = Place.find_by(name: "Kerala Backwaters")

if manali_place
  trip1.add_place(manali_place, 1)
  puts "Added Manali to trip 1"
end

if kerala_place
  trip2.add_place(kerala_place, 1)
  puts "Added Kerala to trip 2"
end

puts "Seed data created successfully!"
puts "Demo user: demo@wanderistan.com / password123"
