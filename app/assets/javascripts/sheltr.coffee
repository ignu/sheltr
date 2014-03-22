app = angular.module("Sheltr", ['ngResource', 'leaflet-directive'])

app.factory('Locations', ['$resource', ($resource) ->
  $resource '/locations.json', null, 'index': { method:'GET' }
])

app.controller "LocationsController", ['$scope', 'Locations', (($scope, Locations) ->
  locations = Locations.query ->
    markers = _.map locations, (location) ->
        lat: location.latitude
        lng: location.longitude
        message: location.name

    angular.extend $scope,
      center:
        lat: locations[5].latitude
        lng: locations[5].longitude
        zoom: 13
      defaults:
        scrollWheelZoom: false
      markers: markers


  $scope.locations = locations

  angular.extend $scope,
    center:
      lat: 39.28026
      lng: -76.65054
      zoom: 11
    markers: {}
    defaults:
      scrollWheelZoom: false
)]

