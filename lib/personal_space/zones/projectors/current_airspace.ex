defmodule PersonalSpace.Zones.Projectors.CurrentAirspace do
  use Commanded.Projections.Ecto,
    application: PersonalSpace.CommandedApp,
    repo: PersonalSpace.Repo,
    name: "PersonalSpace.Zones.Projectors.CurrentAirspace"

  alias PersonalSpace.Zones.Events.{AircraftEntered, AircraftExited, AircraftLogged}
  alias PersonalSpace.Zones.Projections.AircraftsCurrent

  # Aircraft enters — insert new record
  project(%AircraftEntered{} = event, _metadata, fn multi ->
    entered_at = parse_datetime(event.entered_at)

    projection = %AircraftsCurrent{
      icao24: event.icao24,
      zone_id: event.zone_id,
      origin_country: event.origin_country,
      longitude: event.longitude,
      latitude: event.latitude,
      baro_altitude: event.baro_altitude,
      velocity: event.velocity,
      on_ground: event.on_ground,
      time_position: event.time_position,
      last_contact: event.last_contact,
      entered_at: entered_at,
      last_seen_at: entered_at
    }

    Ecto.Multi.insert(multi, :current_airspace, projection,
      on_conflict: :replace_all,
      conflict_target: :icao24
    )
  end)

  # Aircraft logged (still in airspace) — update position and telemetry
  project(%AircraftLogged{} = event, _metadata, fn multi ->
    logged_at = parse_datetime(event.logged_at)

    projection = %AircraftsCurrent{
      icao24: event.icao24,
      zone_id: event.zone_id,
      origin_country: event.origin_country,
      longitude: event.longitude,
      latitude: event.latitude,
      baro_altitude: event.baro_altitude,
      velocity: event.velocity,
      on_ground: event.on_ground,
      time_position: event.time_position,
      last_contact: event.last_contact,
      # best guess if we missed AircraftEntered
      entered_at: logged_at,
      last_seen_at: logged_at
    }

    Ecto.Multi.insert(multi, :current_airspace, projection,
      on_conflict:
        {:replace,
         [
           :longitude,
           :latitude,
           :baro_altitude,
           :velocity,
           :on_ground,
           :time_position,
           :last_contact,
           :last_seen_at,
           :updated_at
         ]},
      conflict_target: :icao24
    )
  end)

  # Aircraft exits — delete from current airspace
  project(%AircraftExited{} = event, _metadata, fn multi ->
    Ecto.Multi.run(multi, :remove_airspace, fn repo, _ ->
      repo.delete_all(from a in AircraftsCurrent, where: a.icao24 == ^event.icao24)
      {:ok, nil}
    end)
  end)

  defp parse_datetime(%DateTime{} = dt), do: dt

  defp parse_datetime(dt) when is_binary(dt) do
    {:ok, parsed, _} = DateTime.from_iso8601(dt)
    parsed
  end
end
