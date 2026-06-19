defmodule PersonalSpace.Zones.Commands.RegisterAirSpace do
  # This command is called by the poller every so oftern after polling the airspace
  # then is a job of the aggregate to determine if it must submit a RegisterEntry or RegisterExit command
  @enforce_keys [:zone_id]
  defstruct [
    :zone_id,
    # list of {callsign, %{icao24:, origin_country:, ...}} tuples
    aircrafts: []
  ]
end
