class Location extends Backbone.Model
class Locations extends Backbone.Collection

class LocationView extends Backbone.Marionette.ItemView
  templateHelpers: =>
  template: _.template """
      <div class="header row">
        <div class="name large-9 columns">
          <h3><a href="<%= url %>"><%= name %></a></h3>

          <span> <%= address1 %> <%= address2 %></span>
          <div> <%= city %>, <%= state %></div>

          <div class="phone">
            <h5> <%= phone %> </h5>
          </div>
        </div>
      </div>

      <div class="details row">
        <div class="large-11 columns">
          <%= description %>

          <div class="hours">
            <strong>Hours</strong>: <%= hours %>
          </div>
        </div>
      </div>
  """

  className: "panel service row"


class MapView
  constructor: (collection, coords) ->
    first = collection.first()

    map = L.map 'map',
      center: [coords.latitude, coords.longitude]
      zoom: 13

    L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { attribution: 'Open Street ', maxZoom: 18 }).addTo(map)

    collection.each (model) ->

      marker = L.marker([model.get("latitude"), model.get("longitude")]).addTo(map)
          .bindPopup(model.get("name") + "<br/> #{model.get("phone") || ''}")

      model.on "focused", ->
        map.setView([model.get("latitude"), model.get("longitude")], 15)
        marker.openPopup()

    collection.first().trigger("focused")
    console.log "collection.last", collection.first()
    window.model = collection.first()

class LocationCollectionView extends Backbone.Marionette.CollectionView
  className: "locations"
  itemView: LocationView

class LocationsController extends Backbone.Marionette.Controller
  initialize: (coords) ->
    locations = new Locations

    params = "latitude=#{coords.latitude}&longitude=#{coords.longitude}"

    locations.url = "/locations.json?#{params}"

    locations.fetch().success ->
      NProgress.done()
      new MapView(locations, coords)
      view = new LocationCollectionView(collection: locations)
      $("#locations").append(view.render().$el)

$ ->
  NProgress.start()

  navigator.geolocation.getCurrentPosition (position) ->
    console.log "position.coords", position.coords
    new LocationsController position.coords

