import { Controller } from "@hotwired/stimulus"
import { debounce } from "lodash-es"

export default class extends Controller {
  static targets = [
    "map", "searchInput", "searchDropdown", "selectedPlaces", "placesList",
    "drawButton", "smartButton", "speedControl", "speedValue", "summary",
    "totalDistance", "totalDuration", "totalCost", "routeLegs", "loading"
  ]

  static values = {
    token: String,
    apiKey: String
  }

  connect() {
    console.log("🔍 Map controller connecting...")
    console.log("🔍 Controller element:", this.element)
    console.log("🔍 Has map target:", this.hasMapTarget)
    console.log("🔍 Map target element:", this.mapTarget)

    this.initializeMap()
    this.setupEventListeners()
    this.selectedPlaces = []
    this.isDrawingMode = false
    this.drawnPoints = []
    this.animationSpeed = 1
    this.isAnimating = false
    this.animationId = null

    console.log("✅ Map controller connected successfully")
  }

  initializeMap() {
    console.log("🔍 Initializing map...")
    console.log("🔍 Map target:", this.mapTarget)
    console.log("🔍 Token value:", this.tokenValue)
    console.log("🔍 API key value:", this.apiKeyValue)

    // Check if mapboxgl is available globally (from CDN)
    if (typeof mapboxgl === 'undefined') {
      console.error('❌ Mapbox GL JS not loaded')
      this.showNotification('Mapbox GL JS not loaded. Please refresh the page.', 'error')
      return
    }

    console.log("✅ Mapbox GL JS is available")

    const accessToken = this.tokenValue || this.apiKeyValue
    console.log("🔍 Using access token:", accessToken ? "Token available" : "No token")

    if (!accessToken) {
      console.error('❌ No Mapbox access token available')
      this.showNotification('Mapbox access token not configured.', 'error')
      return
    }

    mapboxgl.accessToken = accessToken

    try {
      this.map = new mapboxgl.Map({
        container: this.mapTarget,
        style: 'mapbox://styles/mapbox/streets-v11',
        center: [78.9629, 20.5937], // India center
        zoom: 5,
        attributionControl: false,
        logoPosition: 'bottom-right'
      })

      console.log("✅ Map instance created")
      console.log("🔍 Map container dimensions:", this.mapTarget.offsetWidth, "x", this.mapTarget.offsetHeight)
      console.log("🔍 Map container style:", this.mapTarget.style.cssText)

      this.map.on('load', () => {
        console.log('✅ Map loaded successfully')
        console.log('🔍 Map canvas dimensions:', this.map.getCanvas().width, 'x', this.map.getCanvas().height)

        // Remove the loading message
        const loadingMessage = this.mapTarget.querySelector('div[style*="position: absolute"]')
        if (loadingMessage) {
          loadingMessage.remove()
        }

        this.setupMapSources()
      })

      this.map.on('error', (e) => {
        console.error('❌ Map error:', e)
        this.showNotification('Map loading error. Please refresh the page.', 'error')
      })

    } catch (error) {
      console.error('❌ Failed to create map:', error)
      this.showNotification('Failed to initialize map: ' + error.message, 'error')
    }
  }

  setupMapSources() {
    // Add sources for route display
    this.map.addSource('route', {
      type: 'geojson',
      data: {
        type: 'Feature',
        properties: {},
        geometry: {
          type: 'LineString',
          coordinates: []
        }
      }
    })

    this.map.addLayer({
      id: 'route',
      type: 'line',
      source: 'route',
      layout: {
        'line-join': 'round',
        'line-cap': 'round'
      },
      paint: {
        'line-color': '#3b82f6',
        'line-width': 4,
        'line-opacity': 0.8
      }
    })

    // Add source for moving sprites
    this.map.addSource('moving-sprites', {
      type: 'geojson',
      data: {
        type: 'FeatureCollection',
        features: []
      }
    })

    this.map.addLayer({
      id: 'moving-sprites',
      type: 'symbol',
      source: 'moving-sprites',
      layout: {
        'icon-image': 'car-15',
        'icon-size': 1,
        'icon-allow-overlap': true,
        'icon-ignore-placement': true
      }
    })
  }

  setupEventListeners() {
    // Search input event
    this.searchInputTarget.addEventListener('input', debounce((e) => {
      this.handleSearch(e)
    }, 300))

    // Map click for drawing
    this.map.on('click', (e) => {
      if (this.isDrawingMode) {
        this.addDrawPoint(e.lngLat)
      }
    })

    // Double click to finish drawing
    this.map.on('dblclick', (e) => {
      e.preventDefault()
      if (this.isDrawingMode && this.drawnPoints.length >= 2) {
        this.finishDrawing()
      }
    })
  }

  handleSearch(e) {
    const query = e.target.value.trim()
    if (query.length < 2) {
      this.hideSearchDropdown()
      return
    }

    const url = `https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(query)}.json`
    const params = new URLSearchParams({
      access_token: this.tokenValue || this.apiKeyValue,
      types: 'place,poi,address',
      limit: 5
    })

    fetch(`${url}?${params}`)
      .then(response => response.json())
      .then(data => {
        this.displaySearchResults(data.features)
      })
      .catch(error => {
        console.error('Search error:', error)
        this.showNotification('Search failed. Please try again.', 'error')
      })
  }

  displaySearchResults(features) {
    const dropdown = this.searchDropdownTarget
    dropdown.innerHTML = ''

    if (features.length === 0) {
      dropdown.innerHTML = '<div class="search-item">No results found</div>'
    } else {
      features.forEach(feature => {
        const item = document.createElement('div')
        item.className = 'search-item'
        item.textContent = feature.place_name
        item.addEventListener('click', () => {
          this.addPlace(feature)
          this.hideSearchDropdown()
          this.searchInputTarget.value = ''
        })
        dropdown.appendChild(item)
      })
    }

    dropdown.style.display = 'block'
  }

  hideSearchDropdown() {
    this.searchDropdownTarget.style.display = 'none'
  }

  addPlace(feature) {
    const place = {
      name: feature.place_name,
      lat: feature.center[1],
      lng: feature.center[0],
      region: feature.context?.find(c => c.id.startsWith('region'))?.text || ''
    }

    this.selectedPlaces.push(place)
    this.updatePlacesDisplay()
    this.addMarkerToMap(place)
    this.showNotification(`Added: ${place.name}`, 'success')
  }

  addMarkerToMap(place) {
    const el = document.createElement('div')
    el.className = 'place-marker'
    el.style.width = '20px'
    el.style.height = '20px'
    el.style.backgroundColor = '#3b82f6'
    el.style.borderRadius = '50%'
    el.style.border = '2px solid white'

    new mapboxgl.Marker(el)
      .setLngLat([place.lng, place.lat])
      .addTo(this.map)
  }

  updatePlacesDisplay() {
    const list = this.placesListTarget
    list.innerHTML = ''

    this.selectedPlaces.forEach((place, index) => {
      const item = document.createElement('div')
      item.className = 'place-marker'
      item.innerHTML = `
        <span>${index + 1}. ${place.name}</span>
        <button class="remove" onclick="this.removePlace(${index})">×</button>
      `
      list.appendChild(item)
    })
  }

  removePlace(index) {
    this.selectedPlaces.splice(index, 1)
    this.updatePlacesDisplay()
    this.showNotification('Place removed', 'info')
  }

  toggleDrawMode() {
    this.isDrawingMode = !this.isDrawingMode
    this.drawButtonTarget.textContent = this.isDrawingMode ? 'Complete Route' : 'Draw Route'
    this.drawButtonTarget.classList.toggle('active', this.isDrawingMode)

    if (this.isDrawingMode) {
      this.drawnPoints = []
      this.map.getCanvas().style.cursor = 'crosshair'
      this.showNotification('Click on map to draw route points. Double-click to finish.', 'info')
    } else {
      this.map.getCanvas().style.cursor = ''
      this.showNotification('Drawing mode disabled', 'info')
    }
  }

  addDrawPoint(lngLat) {
    this.drawnPoints.push([lngLat.lng, lngLat.lat])

    // Add visual point
    const el = document.createElement('div')
    el.className = 'draw-point'
    new mapboxgl.Marker(el)
      .setLngLat(lngLat)
      .addTo(this.map)

    this.showNotification(`Point ${this.drawnPoints.length} added`, 'info')
  }

  finishDrawing() {
    if (this.drawnPoints.length < 2) {
      this.showNotification('Need at least 2 points to create a route', 'error')
      return
    }

    this.showLoading()

    // Snap to roads
    fetch('/api/snap', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ coordinates: this.drawnPoints })
    })
    .then(response => response.json())
    .then(data => {
      if (data.error) {
        throw new Error(data.error)
      }
      return this.replanRoute(data.geometry)
    })
    .then(routeData => {
      this.hideLoading()
      this.displayRoute(routeData)
      this.isDrawingMode = false
      this.toggleDrawMode() // Reset button
      this.showNotification('Route created successfully!', 'success')
    })
    .catch(error => {
      this.hideLoading()
      console.error('Drawing error:', error)
      this.showNotification('Failed to process drawn route: ' + error.message, 'error')
    })
  }

  replanRoute(snappedGeometry) {
    return fetch('/api/replan', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        snapped_geometry: snappedGeometry,
        current_route: null
      })
    })
    .then(response => response.json())
    .then(data => {
      if (data.error) {
        throw new Error(data.error)
      }
      return data
    })
  }

  generateSmartRoute() {
    if (this.selectedPlaces.length < 2) {
      this.showNotification('Please select at least 2 places first', 'error')
      return
    }

    this.showLoading()

    const requestData = {
      user_id: 1, // TODO: Get from current user
      selected_places: this.selectedPlaces,
      preferences: {
        transport_priority: ['train', 'bus', 'flight'],
        avoid_night_travel: true,
        max_budget: 10000
      },
      time_window: {
        start_date: new Date().toISOString().split('T')[0],
        end_date: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]
      }
    }

    fetch('/api/plan', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify(requestData)
    })
    .then(response => response.json())
    .then(data => {
      this.hideLoading()
      if (data.error) {
        throw new Error(data.error)
      }
      this.displayRoute(data.route_plan)
      this.showNotification('Smart route generated!', 'success')
    })
    .catch(error => {
      this.hideLoading()
      console.error('Smart route error:', error)
      this.showNotification('Failed to generate route: ' + error.message, 'error')
    })
  }

  displayRoute(routePlan) {
    if (!routePlan || !routePlan.legs || routePlan.legs.length === 0) {
      this.showNotification('No route data to display', 'error')
      return
    }

    // Update summary
    this.totalDistanceTarget.textContent = `${routePlan.total?.distance_km || 0} km`
    this.totalDurationTarget.textContent = `${routePlan.total?.duration_minutes || 0} min`
    this.totalCostTarget.textContent = `₹${routePlan.total?.estimated_cost_inr || 0}`

    // Display route legs
    this.routeLegsTarget.innerHTML = ''
    routePlan.legs.forEach((leg, index) => {
      const legElement = document.createElement('div')
      legElement.className = 'leg-item'
      legElement.innerHTML = `
        <div class="leg-title">${leg.from?.name || 'Unknown'} → ${leg.to?.name || 'Unknown'}</div>
        <div class="leg-details">
          Mode: ${leg.mode || 'Unknown'} |
          Duration: ${leg.duration_minutes || 0} min |
          Cost: ₹${leg.estimated_cost_inr || 0}
        </div>
      `
      this.routeLegsTarget.appendChild(legElement)
    })

    // Display route on map
    this.displayRouteOnMap(routePlan.legs)

    // Show summary
    this.summaryTarget.style.display = 'block'
  }

  displayRouteOnMap(legs) {
    const allCoordinates = []

    legs.forEach(leg => {
      if (leg.mapbox_route_geojson && leg.mapbox_route_geojson.geometry) {
        const coords = leg.mapbox_route_geojson.geometry.coordinates
        allCoordinates.push(...coords)
      }
    })

    if (allCoordinates.length > 0) {
      this.map.getSource('route').setData({
        type: 'Feature',
        properties: {},
        geometry: {
          type: 'LineString',
          coordinates: allCoordinates
        }
      })

      // Fit map to route
      const bounds = new mapboxgl.LngLatBounds()
      allCoordinates.forEach(coord => bounds.extend(coord))
      this.map.fitBounds(bounds, { padding: 50 })

      // Initialize moving sprites
      this.initializeMovingSprites(allCoordinates)
    }
  }

  initializeMovingSprites(coordinates) {
    if (!coordinates || coordinates.length < 2) return

    const spriteData = {
      type: 'FeatureCollection',
      features: [{
        type: 'Feature',
        geometry: {
          type: 'Point',
          coordinates: coordinates[0]
        },
        properties: {
          progress: 0,
          coordinates: coordinates
        }
      }]
    }

    this.map.getSource('moving-sprites').setData(spriteData)
    this.spriteData = spriteData
    this.startAnimation()
  }

  startAnimation() {
    if (this.isAnimating) return

    this.isAnimating = true
    this.animationId = requestAnimationFrame(() => this.animateSprite())
  }

  animateSprite() {
    if (!this.isAnimating || !this.spriteData) return

    const feature = this.spriteData.features[0]
    const progress = feature.properties.progress + (0.001 * this.animationSpeed)

    if (progress >= 1) {
      this.isAnimating = false
      return
    }

    const coordinates = feature.properties.coordinates
    const index = Math.floor(progress * (coordinates.length - 1))
    const nextIndex = Math.min(index + 1, coordinates.length - 1)
    const fraction = (progress * (coordinates.length - 1)) - index

    const currentCoord = coordinates[index]
    const nextCoord = coordinates[nextIndex]

    const interpolatedCoord = [
      currentCoord[0] + (nextCoord[0] - currentCoord[0]) * fraction,
      currentCoord[1] + (nextCoord[1] - currentCoord[1]) * fraction
    ]

    feature.geometry.coordinates = interpolatedCoord
    feature.properties.progress = progress

    // Calculate bearing
    const bearing = this.calculateBearing(currentCoord, nextCoord)
    feature.properties.bearing = bearing

    this.map.getSource('moving-sprites').setData(this.spriteData)

    this.animationId = requestAnimationFrame(() => this.animateSprite())
  }

  calculateBearing(from, to) {
    const toRadians = (deg) => deg * Math.PI / 180
    const toDegrees = (rad) => rad * 180 / Math.PI

    const dLon = toRadians(to[0] - from[0])
    const lat1 = toRadians(from[1])
    const lat2 = toRadians(to[1])

    const y = Math.sin(dLon) * Math.cos(lat2)
    const x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLon)

    return toDegrees(Math.atan2(y, x))
  }

  updateSpeed(e) {
    this.animationSpeed = parseFloat(e.target.value)
    this.speedValueTarget.textContent = this.animationSpeed
  }

  clearRoute() {
    // Clear route display
    this.map.getSource('route').setData({
      type: 'Feature',
      properties: {},
      geometry: {
        type: 'LineString',
        coordinates: []
      }
    })

    // Clear sprites
    this.map.getSource('moving-sprites').setData({
      type: 'FeatureCollection',
      features: []
    })

    // Stop animation
    if (this.animationId) {
      cancelAnimationFrame(this.animationId)
      this.isAnimating = false
    }

    // Hide summary
    this.summaryTarget.style.display = 'none'

    // Clear selected places
    this.selectedPlaces = []
    this.updatePlacesDisplay()

    // Clear markers
    const markers = document.querySelectorAll('.mapboxgl-marker')
    markers.forEach(marker => marker.remove())

    this.showNotification('Route cleared', 'info')
  }

  showLoading() {
    this.loadingTarget.style.display = 'flex'
  }

  hideLoading() {
    this.loadingTarget.style.display = 'none'
  }

  showNotification(message, type = 'info') {
    const notification = document.createElement('div')
    notification.className = `notification notification-${type}`
    notification.innerHTML = `
      <i class="fas fa-${type === 'error' ? 'exclamation-circle' : type === 'success' ? 'check-circle' : 'info-circle'}"></i>
      <span>${message}</span>
    `

    document.body.appendChild(notification)

    setTimeout(() => {
      notification.remove()
    }, 3000)
  }
}
