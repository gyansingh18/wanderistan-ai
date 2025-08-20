# 🗺️ Wanderistan - Discover Your Next Adventure

[![Ruby on Rails](https://img.shields.io/badge/Ruby%20on%20Rails-7.1.5-red.svg)](https://rubyonrails.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-13+-blue.svg)](https://www.postgresql.org/)
[![Mapbox](https://img.shields.io/badge/Mapbox-GL%20JS-lightblue.svg)](https://www.mapbox.com/)

**Wanderistan** is a comprehensive travel planning platform that helps you create personalized itineraries with interactive maps and curated video content. Plan your perfect trip with detailed recommendations, explore destinations on beautiful interactive maps, and discover inspiring travel videos from around the world.

## ✨ Features

### 🧠 Intelligent Trip Planning
- **Smart Itinerary Generation**: Creates personalized day-by-day itineraries based on your preferences
- **Budget Estimation**: Realistic budget breakdowns for different destinations
- **Travel Preferences**: Customize based on activity types, travel pace, and preferences
- **Money-Saving Tips**: Helpful tips to optimize your travel budget

### 🗺️ Interactive Map Experience
- **Interactive Mapbox Integration**: Explore destinations on beautiful maps
- **Video Markers**: Click markers to discover travel videos for each location
- **Color-Coded Categories**: Different marker colors for cities, beaches, mountains, etc.
- **Real-time Video Integration**: YouTube videos embedded for each destination

### 📹 Curated Video Content
- **YouTube Integration**: Travel videos from YouTube Data API
- **Location-Specific Videos**: Videos curated for specific destinations
- **Video Categories**: Adventure, culture, food, and more
- **Fallback System**: Sample videos when API quota is exceeded

### 🎯 User Experience
- **Responsive Design**: Works perfectly on desktop, tablet, and mobile
- **Modern UI**: Clean, intuitive interface with Bootstrap 5
- **Fast Loading**: Optimized performance with Turbo and Stimulus
- **User Authentication**: Secure login with Devise

## 🚀 Tech Stack

### Backend
- **Ruby on Rails 7.1.5**: Modern web framework
- **PostgreSQL**: Robust database system
- **Devise**: User authentication and authorization
- **HTTParty**: External API integrations
- **Sidekiq + Redis**: Background job processing

### Frontend
- **Bootstrap 5**: Modern CSS framework
- **Stimulus + Turbo**: Modern JavaScript interactions
- **Mapbox GL JS**: Interactive maps
- **ERB**: Server-side templating

### External APIs
- **YouTube Data API v3**: Travel video integration
- **Mapbox API**: Interactive map functionality

### Development Tools
- **Ransack**: Advanced search functionality
- **Geocoder**: Location-based features
- **Dotenv-rails**: Environment variable management

## 📋 Prerequisites

Before you begin, ensure you have the following installed:
- Ruby 3.2.0 or higher
- Rails 7.1.5
- PostgreSQL 13+
- Node.js 16+ (for asset compilation)
- Redis (for background jobs)

## 🛠️ Installation

### 1. Clone the Repository
```bash
git clone https://github.com/gyansingh18/wanderistan-ai.git
cd wanderistan-ai
```

### 2. Install Dependencies
```bash
bundle install
npm install
```

### 3. Database Setup
```bash
rails db:create
rails db:migrate
rails db:seed
```

### 4. Environment Configuration
Create a `.env` file in the root directory:
```bash
# YouTube Configuration
YOUTUBE_API_KEY=your_youtube_api_key_here

# Mapbox Configuration
MAPBOX_API_KEY=your_mapbox_api_key_here

# Database Configuration
DATABASE_URL=postgresql://localhost/wanderistan_development

# Redis Configuration (for Sidekiq)
REDIS_URL=redis://localhost:6379/0
```

### 5. Start the Application
```bash
# Start Redis (required for background jobs)
redis-server

# Start the Rails server
rails server

# In another terminal, start Sidekiq (for background jobs)
bundle exec sidekiq
```

Visit `http://localhost:3000` to access the application.

## 🔧 API Setup

### YouTube Data API
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project
3. Enable YouTube Data API v3
4. Create credentials (API key)
5. Add to `.env` file as `YOUTUBE_API_KEY`

### Mapbox API
1. Sign up at [Mapbox](https://www.mapbox.com/)
2. Get your access token from the dashboard
3. Add to `.env` file as `MAPBOX_API_KEY`

## 🎮 Usage

### Creating a Trip
1. Navigate to `/trips/planner`
2. Enter your destination and preferences
3. Generate a personalized itinerary based on your inputs
4. Save your trip for later reference

### Exploring the Map
1. Visit `/explore/map`
2. Click on markers to see destination information
3. Click "Watch Videos" to see travel videos
4. Different marker colors indicate categories:
   - 🟢 Green: Countries
   - 🔴 Red: Cities
   - 🟠 Orange: Cultural sites
   - 🟣 Purple: Adventure destinations
   - 🔵 Cyan: Beaches
   - ⚫ Gray: Mountains

### Managing Trips
- View all trips at `/trips`
- Edit trip details
- Delete trips you no longer need
- Share trip itineraries

## 📁 Project Structure

```
wanderistan/
├── app/
│   ├── controllers/          # Rails controllers
│   ├── models/              # Database models
│   ├── services/            # External API services
│   ├── views/               # ERB templates
│   └── helpers/             # View helpers
├── config/                  # Rails configuration
├── db/                      # Database migrations and seeds
├── public/                  # Static files and test pages
└── test/                    # Test files
```

## 🔍 Key Features Explained

### Smart Trip Planning
The platform generates personalized itineraries based on:
- Destination preferences
- Travel duration
- Budget constraints
- Activity preferences
- Accommodation style
- Food preferences

### Interactive Map
The map system provides:
- Real-time location data
- Video integration for each destination
- Category-based filtering
- Responsive design for all devices

### Video Integration
The video system includes:
- YouTube API integration
- Location-specific video curation
- Fallback sample videos
- Video categorization

## 🧪 Testing

Run the test suite:
```bash
rails test
```

For system tests:
```bash
rails test:system
```

## 🚀 Deployment

### Heroku Deployment
1. Create a Heroku app
2. Add PostgreSQL addon
3. Add Redis addon
4. Set environment variables
5. Deploy with Git

```bash
heroku create your-app-name
heroku addons:create heroku-postgresql
heroku addons:create heroku-redis
heroku config:set YOUTUBE_API_KEY=your_key
heroku config:set MAPBOX_API_KEY=your_key
git push heroku master
```

### Docker Deployment
```bash
docker build -t wanderistan .
docker run -p 3000:3000 wanderistan
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **YouTube** for travel video content
- **Mapbox** for interactive map functionality
- **Rails Community** for the amazing framework
- **Bootstrap** for the beautiful UI components

## 📞 Support

If you encounter any issues or have questions:
1. Check the [Issues](https://github.com/gyansingh18/wanderistan/issues) page
2. Create a new issue with detailed information
3. Contact the maintainers

## 🔮 Future Roadmap

- [ ] Real-time collaboration on trip planning
- [ ] Social features (share trips, follow travelers)
- [ ] Mobile app development
- [ ] Enhanced recommendation features
- [ ] Integration with booking platforms
- [ ] Offline map functionality
- [ ] Multi-language support

---

**Made with ❤️ by the Wanderistan Team**

*Plan your next adventure with intelligent recommendations!*
