import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "mapContainer",
    "routeName",
    "searchInput",
    "searchSuggestions",
    "destinationsList",
    "distanceDisplay",
    "durationDisplay",
    "speedDisplay",
    "budgetMode",
    "offlineMode",
    "publicRoute",
    "costContainer",
    "costDisplay",
    "borderInfo",
    "borderDetails",
    "notesContainer"
  ]

  connect() {
    this.showLoading()
    this.initMap()
    this.initializeVariables()
    this.setupEventListeners()
  }

  showLoading() {
    const loading = this.element.querySelector('.map-loading')
    if (loading) loading.classList.remove('d-none')
  }

  hideLoading() {
    const loading = this.element.querySelector('.map-loading')
    if (loading) loading.classList.add('d-none')
  }

  initializeVariables() {
    this.destinations = []
    this.currentRoute = null
    this.searchTimeout = null
    this.animationSpeed = 1
    this.isDrawMode = false
    this.selectedSuggestionIndex = -1
    this.poiLayers = {}
    this.weatherOverlay = null
    this.routeNotes = []
    this.isBudgetMode = false
    this.isOfflineMode = false
    this.borderCrossings = []
  }

  initMap() {
    const token = this.element.dataset.mapboxToken
    if (!token) {
      console.error('Mapbox token not found')
      const mapContainer = this.mapContainerTarget
      mapContainer.innerHTML = `
        <div class="alert alert-danger m-3" role="alert">
          <h4 class="alert-heading">Map Configuration Error</h4>
          <p>The Mapbox API key is missing. Please check your environment configuration.</p>
        </div>
      `
      this.hideLoading()
      return
    }

    mapboxgl.accessToken = token

    this.map = new mapboxgl.Map({
      container: this.mapContainerTarget,
      style: 'mapbox://styles/mapbox/streets-v11',
      center: [77.1025, 28.7041], // New Delhi
      zoom: 5,
      maxBounds: [
        [68.1766451354, 6.5546079374], // Southwest coordinates of India
        [97.395561, 35.6745457] // Northeast coordinates of India
      ]
    })

    this.map.on('load', () => {
      this.hideLoading()
      this.setupMapLayers()
      this.setupMapControls()
    })

    this.map.on('error', (e) => {
      console.error('Mapbox error:', e)
      const mapContainer = this.mapContainerTarget
      mapContainer.innerHTML = `
        <div class="alert alert-danger m-3" role="alert">
          <h4 class="alert-heading">Map Error</h4>
          <p>There was an error loading the map. Please check your internet connection and try again.</p>
          <hr>
          <p class="mb-0">Error details: ${e.error.message}</p>
        </div>
      `
      this.hideLoading()
    })
  }

  setupMapLayers() {
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
  }

  setupMapControls() {
    // Add navigation controls
    this.map.addControl(new mapboxgl.NavigationControl(), 'top-right')

    // Add draw controls
    this.draw = new MapboxDraw({
      displayControlsDefault: false,
      controls: {
        line_string: true,
        trash: true
      }
    })
    this.map.addControl(this.draw)

    // Add geocoder control
    this.geocoder = new MapboxGeocoder({
      accessToken: mapboxgl.accessToken,
      mapboxgl: mapboxgl,
      countries: 'in',
      language: 'en',
      bbox: [68.1766451354, 6.5546079374, 97.395561, 35.6745457], // India bounds
      types: 'place,district,locality,neighborhood,address'
    })
    this.map.addControl(this.geocoder)

    // Setup map event listeners
    this.map.on('draw.create', () => this.handleDrawCreate())
    this.map.on('draw.update', () => this.handleDrawUpdate())
    this.map.on('draw.delete', () => this.handleDrawDelete())

    // Handle geocoder results
    this.geocoder.on('result', (e) => this.handlePlaceSelection(e.result))
  }

  setupEventListeners() {
    // Make destinations list sortable
    new Sortable(this.destinationsListTarget, {
      animation: 150,
      onEnd: () => this.updateRoute()
    })

    // Handle keyboard navigation in search suggestions
    this.searchInputTarget.addEventListener('keydown', (e) => {
      if (!this.searchSuggestionsTarget.classList.contains('d-none')) {
        switch(e.key) {
          case 'ArrowDown':
            e.preventDefault()
            this.navigateSuggestions(1)
            break
          case 'ArrowUp':
            e.preventDefault()
            this.navigateSuggestions(-1)
            break
          case 'Enter':
            e.preventDefault()
            this.selectHighlightedSuggestion()
            break
          case 'Escape':
            this.hideSearchSuggestions()
            break
        }
      }
    })
  }

  // ... rest of the methods ...
}
