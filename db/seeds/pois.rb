# Sample POI data for India
pois_data = [
  # Hostels in Delhi
  {
    name: "Zostel Delhi",
    poi_type: "hostel",
    latitude: 28.6289,
    longitude: 77.2065,
    description: "Popular backpacker hostel with rooftop cafe",
    price: 500,
    rating: 4.5,
    amenities: ["WiFi", "Common Room", "Lockers", "24/7 Reception"],
    opening_hours: {"mon_fri": "24/7", "sat_sun": "24/7"},
    contact_info: "+91 11 2345 6789",
    website: "https://www.zostel.com/zostel/delhi/",
    verified: true
  },

  # Camping near Rishikesh
  {
    name: "Beach Camp Rishikesh",
    poi_type: "camping",
    latitude: 30.0869,
    longitude: 78.2676,
    description: "Riverside camping with adventure activities",
    price: 1200,
    rating: 4.3,
    amenities: ["Tents", "Bonfire", "Rafting", "Meals"],
    opening_hours: {"season": "Oct-Jun"},
    contact_info: "+91 98765 43210",
    website: "https://beachcamprishikesh.com",
    verified: true
  },

  # Trekking Trail in Manali
  {
    name: "Hampta Pass Trek",
    poi_type: "trail",
    latitude: 32.2396,
    longitude: 77.1887,
    description: "Beautiful 4-5 day trek crossing Hampta Pass",
    price: 8000,
    rating: 4.8,
    amenities: ["Guide", "Camping", "Food", "Equipment"],
    opening_hours: {"season": "Jun-Sep"},
    contact_info: "+91 94123 56789",
    website: "https://hamptapass.com",
    verified: true
  },

  # Budget Food in Mumbai
  {
    name: "Sharma Bhelpuri",
    poi_type: "food",
    latitude: 19.0760,
    longitude: 72.8777,
    description: "Famous street food spot at Juhu Beach",
    price: 100,
    rating: 4.6,
    amenities: ["Street Food", "Takeaway"],
    opening_hours: {"daily": "11:00-23:00"},
    contact_info: "+91 98201 23456",
    verified: true
  },

  # Cultural Landmark in Agra
  {
    name: "Taj Mahal",
    poi_type: "cultural",
    latitude: 27.1751,
    longitude: 78.0421,
    description: "UNESCO World Heritage Site and symbol of love",
    price: 1100,
    rating: 5.0,
    amenities: ["Guide", "Museum", "Garden"],
    opening_hours: {"daily": "06:00-18:30", "closed": "Friday"},
    contact_info: "tourism.agra@gov.in",
    website: "https://tajmahal.gov.in",
    verified: true
  }
]

# Create POIs
pois_data.each do |poi_data|
  Poi.create!(poi_data)
end

puts "Created #{Poi.count} POIs"
