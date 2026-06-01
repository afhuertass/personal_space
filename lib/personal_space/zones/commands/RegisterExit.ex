defmodule PersonalSpace.Zones.Commands.RegisterExit do
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
    :velocity
  ]
end
