defmodule PersonalSpace.Zones.Projectors.AircraftsEntered do
  alias PersonalSpace.Zones.Events.AircraftEntered
  alias PersonalSpace.Zones.Projections.AircraftsEnter, as: Aircraft_projection

  use Commanded.Projections.Ecto,
    application: PersonalSpace.CommandedApp,
    repo: PersonalSpace.Repo,
    name: "zone_entries"

  project(%AircraftEntered{} = event, meta, fn multi ->
    entered_at =
      case event.entered_at do
        # already a DateTime, use as-is
        %DateTime{} = dt ->
          dt

        # it's a string, parse it
        dt when is_binary(dt) ->
          {:ok, parsed, _} = DateTime.from_iso8601(dt)
          parsed
      end

    project = %Aircraft_projection{
      event_id: meta.event_id,
      zone_id: event.zone_id,
      icao24: event.icao24,
      origin_country: event.origin_country,
      velocity: event.velocity,
      entered_at: entered_at,
      latitude: event.latitude,
      longitude: event.longitude
    }

    Ecto.Multi.insert(multi, :zone_entries, project,
      on_conflict: :nothing,
      conflict_target: :event_id
    )
  end)
end
