defmodule PersonalSpace.Zones.Commands.RegisterEntry do
  # Exits typically don't need telemetry because the aircraft is gone,
  # but keeping coordinates or last contact can be helpful for debugging!
  @enforce_keys [:zone_id, :icao24]
  defstruct [
    :zone_id,
    :icao24,
    :origin_country,
    :time_position,
    :last_contact,
    :longitude,
    :latitude,
    :baro_altitude,
    :on_ground,
    :velocity,
    :entered_at
  ]
end
