json.array!(@locations) do |location|
  json.extract! location, :id, :name, :address1, :address2, :city, :state, :lat, :long, :hours, :phone, :url, :description, :eligibility
  json.url location_url(location, format: :json)
end
