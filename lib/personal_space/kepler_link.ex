defmodule PersonalSpace.KeplerLink do
  @base_url "https://kepler.gl/demo"

  def generate(hours \\ 24) do
    data_url =
      "http://dg06h8difqv1i4716lwtfj69.89.167.124.166.sslip.io/api/flights/geojson"

    encoded = URI.encode(data_url)
    "#{@base_url}?mapUrl=#{encoded}"
  end
end
