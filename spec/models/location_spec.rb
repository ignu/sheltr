require 'spec_helper'

describe Location do
  let(:lat)    { -75.1468956 }
  let(:long)   { 39.9524206 }

  let!(:far)   { Location.create!(latitude: lat - 3,   longitude: long - 3) }
  let!(:near)  { Location.create!(latitude: lat - 0.1, longitude: long - 0.1) }
  let!(:exact) { Location.create!(latitude: lat, longitude: long) }

  it "can find nearby locations" do
    locations = Location.near([lat, long], 20)
    locations.length.should == 2
    locations.first.should == exact
  end
end
