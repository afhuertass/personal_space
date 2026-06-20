defmodule PersonalSpace.Zones.Queries do
  import Ecto.Query
  alias PersonalSpace.Repo
  alias PersonalSpace.Zones.Projections.AircraftsEnter

  @home_lat String.to_float(System.get_env("HOME_LAT", "0.0"))
  @home_lon String.to_float(System.get_env("HOME_LON", "0.0"))

  def aircrafts_past1h() do
    since = DateTime.utc_now() |> DateTime.add(-1, :hour)
    fetch_since(since)
  end

  def aircrafts_past24h() do
    since = DateTime.utc_now() |> DateTime.add(-24, :hour)
    fetch_since(since)
  end

  def aircrafts_past12h() do
    since = DateTime.utc_now() |> DateTime.add(-12, :hour)
    fetch_since(since)
  end

  def furthest_plane() do
    case aircrafts_past24h() do
      [] ->
        nil

      aircrafts ->
        {icao24, country, {lat, lon}, entered_at} =
          Enum.max_by(aircrafts, fn {_icao24, _country, {lat, lon}, _} ->
            haversine_km({lat, lon}, {@home_lat, @home_lon})
          end)

        distance = haversine_km({lat, lon}, {@home_lat, @home_lon})

        {icao24, country, {lat, lon}, entered_at, Float.round(distance, 1)}
    end
  end

  def countries_count_past24h() do
    since = DateTime.utc_now() |> DateTime.add(-24, :hour)
    countries_count_since(since)
  end

  def countries_count_past12h() do
    since = DateTime.utc_now() |> DateTime.add(-12, :hour)
    countries_count_since(since)
  end

  # --- private ---

  defp fetch_since(since) do
    Repo.all(
      from a in AircraftsEnter,
        where: a.entered_at >= ^since,
        distinct: a.icao24,
        order_by: [desc: a.entered_at],
        select: {a.icao24, a.origin_country, a.latitude, a.longitude, a.entered_at}
    )
    |> Enum.map(fn {icao24, country, lat, lon, entered_at} ->
      {icao24, country, {lat, lon}, entered_at}
    end)
  end

  defp countries_count_since(since) do
    Repo.all(
      from a in AircraftsEnter,
        where: a.entered_at >= ^since,
        group_by: a.origin_country,
        order_by: [desc: count(a.origin_country)],
        select: {a.origin_country, count(a.origin_country)}
    )
    |> Enum.map(fn {country, count} ->
      {country, count}
    end)
  end

  # Haversine formula — returns distance in km between two {lat, lon} points
  defp haversine_km({lat1, lon1}, {lat2, lon2}) do
    # Earth radius in km
    r = 6371

    dlat = to_rad(lat2 - lat1)
    dlon = to_rad(lon2 - lon1)

    a =
      :math.sin(dlat / 2) * :math.sin(dlat / 2) +
        :math.cos(to_rad(lat1)) * :math.cos(to_rad(lat2)) *
          :math.sin(dlon / 2) * :math.sin(dlon / 2)

    c = 2 * :math.atan2(:math.sqrt(a), :math.sqrt(1 - a))
    r * c
  end

  defp to_rad(deg), do: deg * :math.pi() / 180
end
