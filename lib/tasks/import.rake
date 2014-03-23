namespace "locations" do
  class Importer
    def import
      file = File.open filename

      CSV.foreach(file.path, headers: true) do |row|
        hash = construct_hash(row)
        clean_hash(hash)
        Location.create! hash if hash["address1"]
      end
    end

    def clean_hash(hash)
      hash["longitude"] = (-hash["longitude"].to_f) if hash["longitude"].to_f > 0

      if (hash["url"] && !(hash["url"].include?("http")))
         hash["url"] = "http://#{hash['url']}"
      end
    end

    def construct_hash(row)
      rv = Hash.new
        mapping.each do |k, v|
          rv[mapping[k]] = row[k]
        end
      rv
    end
  end

  class PhiladelphiaImporter < Importer
    attr_reader :filename

    def initialize
      @filename = "./lib/tasks/phl-food-resources.csv"
    end

    def clean_hash(hash)
      hash["state"] = "PA"
      super
    end

    def construct_hash(row)
      combine_hours_for(row)
      super
    end

    def combine_hours_for(row)
      row["Hours"] = ""
      %w{Sunday  Monday  Tuesday Wednesday Thursday  Friday  Saturday}.each do |day|
        if row[day]
          row["Hours"] += "#{day}: #{row[day]} "
        end
      end
    end

    def mapping
      {
        "Organization Name" => "name",
        "Street Address" => "address1",
        "City"    => "city",
        "PhysicalPostalCode" => "zip",
        "Latitude" => "latitude",
        "Longitude" => "longitude",
        "Hours" => "hours",
        "Notes" => "description"
      }
    end
  end

  class BaltimoreImporter < Importer
    attr_reader :filename

    def initialize
      @filename = "./lib/tasks/baltimore.csv"
    end

    def mapping
      {
        "PublicName" => "name",
        "PhysicalAddress1" => "address1",
        "PhysicalAddress2" => "address2",
        "PhysicalCity"    => "city",
        "PhysicalStateProvince" => "state",
        "PhysicalPostalCode" => "zip",
        "Latitude" => "latitude",
        "Longitude" => "longitude",
        "HoursOfOperation" => "hours",
        "Phone1Number" => "phone",
        "WebsiteAddress" => "url",
        "Eligibility" => "eligibility"
      }
    end
  end

  task import: :environment do
    require 'csv'

    Location.delete_all
    p '-' * 88
    p "Starting import. #{Location.count} locations."

    BaltimoreImporter.new.import
    PhiladelphiaImporter.new.import

    p "IMPORT COMPLETE.... #{Location.count} locations."
    p '-' * 88
  end

  task geocode: :environment do
    locations = Location.where(latitude: nil)
    locations.each do |location|
      p "Setting Location for #{location.full_address}......."
      result = Geocoder.search location.full_address
      p "(#{result})"
      p '-' * 88
      if result.first
        location.latitude = result.first.geometry["location"]["lat"]
        location.latitude = result.first.geometry["location"]["lng"]
        location.save!
      else
        p "*" * 33
        p "NO RESULT FOUND for #{location.full_address}"
        p "*" * 33
      end
    end
  end
end
