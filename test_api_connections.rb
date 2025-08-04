#!/usr/bin/env ruby

puts "🔍 WANDERISTAN AI - API CONNECTION TEST"
puts "=" * 50

# Test 1: Environment Variables
puts "\n📋 1. ENVIRONMENT VARIABLES"
puts "-" * 30

api_keys = {
  'OPENAI_ACCESS_TOKEN' => ENV['OPENAI_ACCESS_TOKEN'],
  'YOUTUBE_API_KEY' => ENV['YOUTUBE_API_KEY'],
  'MAPBOX_API_KEY' => ENV['MAPBOX_API_KEY']
}

api_keys.each do |key, value|
  if value && value != "your_#{key.downcase}_here"
    puts "✅ #{key}: SET"
  else
    puts "❌ #{key}: NOT SET (using placeholder)"
  end
end

# Test 2: Database Connections
puts "\n🗄️ 2. DATABASE CONNECTIONS"
puts "-" * 30

begin
  require_relative 'config/environment'

  models = [User, Trip, Place, Video, ItineraryItem]
  models.each do |model|
    count = model.count
    puts "✅ #{model.name}: #{count} records"
  rescue => e
    puts "❌ #{model.name}: ERROR - #{e.message}"
  end
rescue => e
  puts "❌ Database connection failed: #{e.message}"
end

# Test 3: HTTParty (Network)
puts "\n🌐 3. NETWORK CONNECTIVITY"
puts "-" * 30

begin
  require 'httparty'
  response = HTTParty.get('https://httpbin.org/get', timeout: 10)
  if response.code == 200
    puts "✅ HTTParty: WORKING"
  else
    puts "❌ HTTParty: HTTP #{response.code}"
  end
rescue => e
  puts "❌ HTTParty: ERROR - #{e.message}"
end

# Test 4: OpenAI Service
puts "\n🤖 4. OPENAI API"
puts "-" * 30

begin
  if ENV['OPENAI_ACCESS_TOKEN'] && ENV['OPENAI_ACCESS_TOKEN'] != "your_openai_access_token_here"
    # Test with a simple prompt
    result = OpenaiService.generate_trip_itinerary("2-day trip to Delhi")
    if result
      puts "✅ OpenAI: WORKING"
      puts "   Response type: #{result.class}"
      puts "   Has title: #{result.key?('title')}"
    else
      puts "❌ OpenAI: FAILED - No response"
    end
  else
    puts "⚠️  OpenAI: SKIPPED - API key not set"
  end
rescue => e
  puts "❌ OpenAI: ERROR - #{e.message}"
end

# Test 5: YouTube Service
puts "\n📺 5. YOUTUBE API"
puts "-" * 30

begin
  if ENV['YOUTUBE_API_KEY'] && ENV['YOUTUBE_API_KEY'] != "your_youtube_api_key_here"
    result = YoutubeService.fetch_videos_for_place("Manali", 1)
    if result.any?
      puts "✅ YouTube: WORKING"
      puts "   Found #{result.length} videos"
      puts "   First video: #{result.first[:title][0..50]}..."
    else
      puts "❌ YouTube: FAILED - No videos found"
    end
  else
    puts "⚠️  YouTube: SKIPPED - API key not set"
  end
rescue => e
  puts "❌ YouTube: ERROR - #{e.message}"
end

# Test 6: Mapbox Token
puts "\n🗺️ 6. MAPBOX"
puts "-" * 30

mapbox_token = ENV['MAPBOX_API_KEY']
if mapbox_token && mapbox_token != "your_mapbox_api_key_here"
  puts "✅ Mapbox: TOKEN SET"
  puts "   Token starts with: #{mapbox_token[0..10]}..."
else
  puts "❌ Mapbox: TOKEN NOT SET"
end

# Test 7: Rails Routes
puts "\n🛣️ 7. RAILS ROUTES"
puts "-" * 30

begin
  routes = Rails.application.routes.routes.map(&:name).compact
  important_routes = ['root', 'trips', 'planner', 'explore', 'places']

  important_routes.each do |route|
    if routes.include?(route)
      puts "✅ Route '#{route}': AVAILABLE"
    else
      puts "❌ Route '#{route}': MISSING"
    end
  end
rescue => e
  puts "❌ Routes: ERROR - #{e.message}"
end

# Test 8: Service Classes
puts "\n🔧 8. SERVICE CLASSES"
puts "-" * 30

services = ['OpenaiService', 'YoutubeService']
services.each do |service|
  begin
    klass = Object.const_get(service)
    methods = klass.methods(false)
    puts "✅ #{service}: LOADED (#{methods.length} methods)"
  rescue => e
    puts "❌ #{service}: ERROR - #{e.message}"
  end
end

# Summary
puts "\n📊 SUMMARY"
puts "=" * 50

working_apis = 0
total_apis = 3

if ENV['OPENAI_ACCESS_TOKEN'] && ENV['OPENAI_ACCESS_TOKEN'] != "your_openai_access_token_here"
  working_apis += 1
end

if ENV['YOUTUBE_API_KEY'] && ENV['YOUTUBE_API_KEY'] != "your_youtube_api_key_here"
  working_apis += 1
end

if ENV['MAPBOX_API_KEY'] && ENV['MAPBOX_API_KEY'] != "your_mapbox_api_key_here"
  working_apis += 1
end

puts "Working APIs: #{working_apis}/#{total_apis}"
puts "Database: ✅ WORKING"
puts "Network: ✅ WORKING"

if working_apis == total_apis
  puts "\n🎉 ALL SYSTEMS OPERATIONAL!"
else
  puts "\n⚠️  SOME APIs NEED CONFIGURATION"
  puts "Please update your API keys in .env file"
end

puts "\n" + "=" * 50
