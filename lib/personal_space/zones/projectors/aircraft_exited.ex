defmodule PersonalSpace.Zones.Projectors.AircraftExited do
  alias PersonalSpace.Zones.Events.AircraftExited
  alias PersonalSpace.Zones.Projections.AircraftsExited, as: Aircraft_projection

  use Commanded.Projections.Ecto,
    application: PersonalSpace.CommandedApp,
    repo: PersonalSpace.Repo,
    name: "zone_exits"

  project(%AircraftExited{} = event, _meta, fn multi ->
    occurred_at =
      case event.occurred_at do
        # already a DateTime, use as-is
        %DateTime{} = dt ->
          dt

        # it's a string, parse it
        dt when is_binary(dt) ->
          {:ok, parsed, _} = DateTime.from_iso8601(dt)
          parsed
      end

    projection = %Aircraft_projection{
      zone_id: event.zone_id,
      icao24: event.icao24,
      origin_country: event.origin_country,
      velocity: event.velocity,
      occurred_at: occurred_at
    }

    Ecto.Multi.insert(multi, :zone_exits, projection)
  end)
end
