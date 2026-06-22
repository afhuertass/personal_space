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

  def yesterday_summary() do
    {yesterday_start, yesterday_end} = yesterday_range()

    total_flights =
      Repo.aggregate(
        from(a in AircraftsEnter,
          where: a.entered_at >= ^yesterday_start,
          where: a.entered_at < ^yesterday_end
        ),
        :count
      )

    total_countries =
      Repo.one(
        from a in AircraftsEnter,
          where: a.entered_at >= ^yesterday_start,
          where: a.entered_at < ^yesterday_end,
          select: count(a.origin_country, :distinct)
      )

    {most_common, most_common_count} =
      Repo.one(
        from a in AircraftsEnter,
          where: a.entered_at >= ^yesterday_start,
          where: a.entered_at < ^yesterday_end,
          group_by: a.origin_country,
          order_by: [desc: count(a.origin_country)],
          limit: 1,
          select: {a.origin_country, count(a.origin_country)}
      )

    {busiest_hour, busiest_count} =
      Repo.one(
        from a in AircraftsEnter,
          where: a.entered_at >= ^yesterday_start,
          where: a.entered_at < ^yesterday_end,
          group_by: fragment("date_part('hour', ?)", a.entered_at),
          order_by: [desc: count(a.icao24)],
          limit: 1,
          select: {fragment("date_part('hour', ?)", a.entered_at), count(a.icao24)}
      )

    {furthest_icao, furthest_country, furthest_lat, furthest_lon} =
      Repo.all(
        from a in AircraftsEnter,
          where: a.entered_at >= ^yesterday_start,
          where: a.entered_at < ^yesterday_end,
          distinct: a.icao24,
          select: {a.icao24, a.origin_country, a.latitude, a.longitude}
      )
      |> Enum.max_by(fn {_, _, lat, lon} ->
        haversine_km({lat, lon}, {@home_lat, @home_lon})
      end)

    furthest_distance =
      haversine_km({furthest_lat, furthest_lon}, {@home_lat, @home_lon})
      |> Float.round(1)

    hour_int = trunc(busiest_hour)
    next_hour = hour_int + 1

    %{
      total_flights: total_flights,
      total_countries: total_countries,
      most_common: {most_common, most_common_count},
      furthest: {furthest_icao, furthest_country, furthest_distance},
      busiest_hour: {"#{hour_int}:00–#{next_hour}:00", busiest_count}
    }
  end

  # --- private ---
  defp yesterday_range() do
    today = DateTime.utc_now() |> DateTime.truncate(:second)
    yesterday = DateTime.add(today, -1, :day)
    start = %{yesterday | hour: 0, minute: 0, second: 0}
    finish = %{yesterday | hour: 23, minute: 59, second: 59}
    {start, finish}
  end

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
  defp haversine_km({nil, _}, _), do: 0.0
  defp haversine_km({_, nil}, _), do: 0.0

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
