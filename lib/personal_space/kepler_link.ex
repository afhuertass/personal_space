defmodule PersonalSpace.KeplerLink do
  @base_url "https://kepler.gl/demo"

  def generate(hours \\ 24) do
    data_url =
      "https://personal-space-server.tailaa2ed8.ts.net/api/flights/flights.geojson"

    encoded = URI.encode(data_url)
    "#{@base_url}?mapUrl=#{encoded}"
  end
end
