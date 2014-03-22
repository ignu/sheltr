namespace "import" do
  task locations: :environment do
    require 'csv'
    filename = "./lib/tasks/baltimore.csv"
    file = File.open filename

    CSV.foreach(file.path, headers: true) do |row|
      hash = construct_hash(row)
      Location.create! hash
    end
  end

  private

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
      "Latitude" => "lat",
      "Longitude" => "long",
      "HoursOfOperation" => "hours",
      "Phone1Number" => "phone",
      "WebsiteAddress" => "url",
      "Eligibility" => "eligibility"
    }
  end
end
