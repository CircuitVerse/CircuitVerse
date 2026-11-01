# frozen_string_literal: true

Geocoder.configure(lookup: :test, ip_lookup: :test)
Geocoder::Lookup::Test.set_default_stub(
  [
    {
      "coordinates" => [40.7143528, -74.0059731],
      "address" => "New York, NY, USA",
      "country" => "United States",
      "country_code" => "US"
    }
  ]
)
