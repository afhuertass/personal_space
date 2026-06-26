defmodule PersonalSpace.Zones.Events.AircraftLogged do
  @derive [Jason.Encoder]
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
    :logged_at
  ]
end
