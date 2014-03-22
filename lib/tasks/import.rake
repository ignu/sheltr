namespace "import" do
  task locations: :environment do
    require 'csv'
    filename = "./lib/tasks/baltimore.csv"
    file = File.open filename

    p '-' * 88
    Location.delete_all

    p "Starting import. #{Location.count} locations."

    CSV.foreach(file.path, headers: true) do |row|
      hash = construct_hash(row)
      clean_hash(hash)
      Location.create! hash
    end

    p "IMPORT COMPLETE.... #{Location.count} locations."
    p '-' * 88
  end

  private

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
