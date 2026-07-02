const LeafletMap = {
  mounted() {
    this.markers = {}
    this.loadLeaflet().then(() => {
      this.initMap()
      this.observeData()  // watch for stream updates
    })
  },

  observeData() {
    const dataDiv = document.getElementById("aircraft-data")
    if (!dataDiv) return

    // MutationObserver watches for DOM changes made by LiveView stream
    this.observer = new MutationObserver(() => {
      this.syncMarkersFromDOM()
    })

    this.observer.observe(dataDiv, {
      childList: true,      // watch for added/removed nodes
      subtree: true,        // watch children too
      attributes: true      // watch for attribute changes (position updates)
    })

    // initial render
    this.syncMarkersFromDOM()
  },

  syncMarkersFromDOM() {
    const dataDiv = document.getElementById("aircraft-data")
    if (!dataDiv || !this.map) return

    const currentIds = new Set()

    // read all aircraft from hidden spans
    dataDiv.querySelectorAll("span[data-icao24]").forEach(el => {
      const icao24   = el.dataset.icao24
      const lat      = parseFloat(el.dataset.lat)
      const lon      = parseFloat(el.dataset.lon)
      const country  = el.dataset.country
      const altitude = el.dataset.altitude
      const speed    = el.dataset.speed

      if (!lat || !lon) return
      currentIds.add(icao24)

      if (this.markers[icao24]) {
        // update existing marker position
        this.markers[icao24].setLatLng([lat, lon])
      } else {
        // add new marker
        this.markers[icao24] = L.marker([lat, lon], {
          icon: L.divIcon({ html: "✈️", className: "", iconSize: [20, 20] })
        })
        .addTo(this.map)
        .bindPopup(`
          <b>${icao24}</b><br>
          🌍 ${country}<br>
          📏 ${altitude ? Math.round(altitude) + 'm' : 'N/A'}<br>
          💨 ${speed ? Math.round(speed) + 'm/s' : 'N/A'}
        `)
      }
    })

    // remove markers for aircraft no longer in stream
    Object.keys(this.markers).forEach(icao24 => {
      if (!currentIds.has(icao24)) {
        this.map.removeLayer(this.markers[icao24])
        delete this.markers[icao24]
      }
    })
  },

  loadLeaflet() {
    return new Promise((resolve) => {
      if (window.L) return resolve()
      const link = document.createElement("link")
      link.rel = "stylesheet"
      link.href = "https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
      document.head.appendChild(link)
      const script = document.createElement("script")
      script.src = "https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
      script.onload = resolve
      document.head.appendChild(script)
    })
  },

  initMap() {
    this.map = L.map(this.el).setView([60.18006, 24.8468], 7)
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: "© OpenStreetMap"
    }).addTo(this.map)
    L.marker([60.18006, 24.8468], {
      icon: L.divIcon({ html: "📡", className: "", iconSize: [30, 30] })
    }).addTo(this.map).bindPopup("Your antenna")
  },

  destroyed() {
    if (this.observer) this.observer.disconnect()
  }
}

export default LeafletMap
