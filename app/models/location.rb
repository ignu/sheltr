class Location < ActiveRecord::Base
  geocoded_by :address1
end
