class Location < ActiveRecord::Base
  geocoded_by :address1

  def full_address
    "#{address1} #{address2}\n #{city}, #{state} #{zip}".squish
  end
end
