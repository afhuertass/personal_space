defmodule PersonalSpaceWeb.FlightController do
  use PersonalSpaceWeb, :controller

  def geojson(conn, _params) do
    aircrafts = PersonalSpace.Zones.Queries.aircrafts_past24h()

    features =
      aircrafts
      |> Enum.filter(fn {_, _, {lat, lon}, _} -> lat != nil and lon != nil end)
      |> Enum.map(fn {icao24, country, {lat, lon}, entered_at} ->
        %{
          type: "Feature",
          geometry: %{
            type: "Point",
            coordinates: [lon, lat]
          },
          properties: %{
            icao24: icao24,
            country: country,
            # kepler expects ms
            timestamp: DateTime.to_unix(entered_at) * 1000,
            entered_at: DateTime.to_iso8601(entered_at)
          }
        }
      end)

    geojson = %{type: "FeatureCollection", features: features}

    conn
    # CORS for kepler.gl
    |> put_resp_header("access-control-allow-origin", "*")
    |> json(geojson)
  end
end
