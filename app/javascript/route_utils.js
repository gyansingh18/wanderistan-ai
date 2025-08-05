// Route Utilities Helper Module
// Provides geometric functions for route planning and animation

export const RouteUtils = {
  /**
   * Sample a line at regular intervals
   * @param {Array} coordinates - Array of [lng, lat] coordinates
   * @param {number} maxPoints - Maximum number of points to sample
   * @returns {Array} Sampled coordinates
   */
  sampleLine(coordinates, maxPoints = 50) {
    if (coordinates.length <= maxPoints) return coordinates

    const step = coordinates.length / maxPoints
    const sampled = []

    for (let i = 0; i < maxPoints; i++) {
      const index = Math.floor(i * step)
      sampled.push(coordinates[index])
    }

    return sampled
  },

  /**
   * Calculate distance between two points using Haversine formula
   * @param {Array} point1 - [lng, lat]
   * @param {Array} point2 - [lng, lat]
   * @returns {number} Distance in kilometers
   */
  distanceBetween(point1, point2) {
    const R = 6371 // Earth's radius in km
    const dLat = (point2[1] - point1[1]) * Math.PI / 180
    const dLon = (point2[0] - point1[0]) * Math.PI / 180
    const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
              Math.cos(point1[1] * Math.PI / 180) * Math.cos(point2[1] * Math.PI / 180) *
              Math.sin(dLon/2) * Math.sin(dLon/2)
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    return R * c
  },

  /**
   * Calculate total distance along a line
   * @param {Array} points - Array of [lng, lat] coordinates
   * @returns {number} Total distance in kilometers
   */
  lineDistance(points) {
    let distance = 0
    for (let i = 1; i < points.length; i++) {
      distance += this.distanceBetween(points[i-1], points[i])
    }
    return distance
  },

  /**
   * Calculate bearing between two points
   * @param {Array} point1 - [lng, lat]
   * @param {Array} point2 - [lng, lat]
   * @returns {number} Bearing in degrees (0-360)
   */
  bearingBetween(point1, point2) {
    const dLon = (point2[0] - point1[0]) * Math.PI / 180
    const lat1 = point1[1] * Math.PI / 180
    const lat2 = point2[1] * Math.PI / 180

    const y = Math.sin(dLon) * Math.cos(lat2)
    const x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLon)

    return (Math.atan2(y, x) * 180 / Math.PI + 360) % 360
  },

  /**
   * Get coordinates along a line at a specific distance
   * @param {Array} coordinates - Line coordinates
   * @param {number} distance - Distance along line (0-1)
   * @returns {Array} [lng, lat] coordinate
   */
  getCoordsAlongLine(coordinates, distance) {
    if (coordinates.length < 2) return coordinates[0]

    const totalDistance = this.lineDistance(coordinates)
    const targetDistance = distance * totalDistance

    let currentDistance = 0
    for (let i = 1; i < coordinates.length; i++) {
      const segmentDistance = this.distanceBetween(coordinates[i-1], coordinates[i])
      if (currentDistance + segmentDistance >= targetDistance) {
        const ratio = (targetDistance - currentDistance) / segmentDistance
        return this.interpolate(coordinates[i-1], coordinates[i], ratio)
      }
      currentDistance += segmentDistance
    }

    return coordinates[coordinates.length - 1]
  },

  /**
   * Interpolate between two points
   * @param {Array} point1 - [lng, lat]
   * @param {Array} point2 - [lng, lat]
   * @param {number} ratio - Interpolation ratio (0-1)
   * @returns {Array} Interpolated [lng, lat]
   */
  interpolate(point1, point2, ratio) {
    return [
      point1[0] + (point2[0] - point1[0]) * ratio,
      point1[1] + (point2[1] - point1[1]) * ratio
    ]
  },

  /**
   * Simplify a line using Douglas-Peucker algorithm
   * @param {Array} coordinates - Line coordinates
   * @param {number} tolerance - Tolerance for simplification
   * @returns {Array} Simplified coordinates
   */
  simplify(coordinates, tolerance = 0.0001) {
    if (coordinates.length <= 2) return coordinates

    const perpendicularDistance = (point, lineStart, lineEnd) => {
      const A = point[1] - lineStart[1]
      const B = lineStart[0] - lineEnd[0]
      const C = lineEnd[1] - lineStart[1]
      const D = point[0] - lineStart[0]

      const numerator = Math.abs(A * B + C * D)
      const denominator = Math.sqrt(B * B + C * C)

      return numerator / denominator
    }

    const douglasPeucker = (points, start, end) => {
      if (end - start <= 1) return

      let maxDistance = 0
      let maxIndex = start

      for (let i = start + 1; i < end; i++) {
        const distance = perpendicularDistance(points[i], points[start], points[end])
        if (distance > maxDistance) {
          maxDistance = distance
          maxIndex = i
        }
      }

      if (maxDistance > tolerance) {
        douglasPeucker(points, start, maxIndex)
        douglasPeucker(points, maxIndex, end)
      } else {
        for (let i = start + 1; i < end; i++) {
          points[i] = null
        }
      }
    }

    const points = [...coordinates]
    douglasPeucker(points, 0, points.length - 1)
    return points.filter(point => point !== null)
  },

  /**
   * Create a bounding box from coordinates
   * @param {Array} coordinates - Array of [lng, lat] coordinates
   * @returns {Object} Bounding box {minLng, maxLng, minLat, maxLat}
   */
  getBoundingBox(coordinates) {
    let minLng = Infinity, maxLng = -Infinity
    let minLat = Infinity, maxLat = -Infinity

    coordinates.forEach(coord => {
      minLng = Math.min(minLng, coord[0])
      maxLng = Math.max(maxLng, coord[0])
      minLat = Math.min(minLat, coord[1])
      maxLat = Math.max(maxLat, coord[1])
    })

    return { minLng, maxLng, minLat, maxLat }
  },

  /**
   * Calculate center point of coordinates
   * @param {Array} coordinates - Array of [lng, lat] coordinates
   * @returns {Array} Center [lng, lat]
   */
  getCenter(coordinates) {
    const sumLng = coordinates.reduce((sum, coord) => sum + coord[0], 0)
    const sumLat = coordinates.reduce((sum, coord) => sum + coord[1], 0)

    return [sumLng / coordinates.length, sumLat / coordinates.length]
  },

  /**
   * Convert degrees to radians
   * @param {number} degrees
   * @returns {number} Radians
   */
  toRadians(degrees) {
    return degrees * Math.PI / 180
  },

  /**
   * Convert radians to degrees
   * @param {number} radians
   * @returns {number} Degrees
   */
  toDegrees(radians) {
    return radians * 180 / Math.PI
  }
}

export default RouteUtils
