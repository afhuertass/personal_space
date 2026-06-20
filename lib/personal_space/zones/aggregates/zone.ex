defmodule PersonalSpace.Zones.Aggregates.Zone do
  defstruct zone: nil, tracked_aircraft: MapSet.new()

  alias PersonalSpace.Zones.Aggregates.Zone, as: Zone
  alias Commanded.Aggregates.Aggregate
  ## Commands alias

  alias PersonalSpace.Zones.Commands.RegisterEntry, as: RegisterEntry
  alias PersonalSpace.Zones.Commands.RegisterExit, as: RegisterExit
  alias PersonalSpace.Zones.Commands.RegisterAirSpace, as: RegisterAirSpace

  ## Alias the events 

  alias PersonalSpace.Zones.Events.AircraftEntered, as: AircraftEntered
  alias PersonalSpace.Zones.Events.AircraftExited, as: AircraftExited

  @behaviour Aggregate

  ## public API

  @impl Aggregate
  def execute(%Zone{tracked_aircraft: tracked_aircraft}, %RegisterAirSpace{} = cmd) do
    all_events =
      Enum.map(cmd.aircrafts, fn %{callsign: callsign} = aircraft_data ->
        # If the aircraft IS NOT in the tracked_aircraft emit an event
        # it means the aircraft entered the airspace
        if not MapSet.member?(tracked_aircraft, callsign) do
          # aicraft NOT in the map, emmit event

          event = %AircraftEntered{
            zone_id: cmd.zone_id,
            icao24: callsign,
            origin_country: aircraft_data.origin_country,
            time_position: aircraft_data.time_position,
            last_contact: aircraft_data.last_contact,
            longitude: aircraft_data.longitude,
            latitude: aircraft_data.latitude,
            baro_altitude: aircraft_data.baro_altitude,
            on_ground: aircraft_data.on_ground,
            velocity: aircraft_data.velocity,
            entered_at: DateTime.utc_now()
          }

          event
        end

        # We iterate over the aifracts in the current airspace. now if the state 
      end)
      |> Enum.reject(&is_nil/1)

    ## TODO
    ## now we need to validate what happens if the the State has an element that the Airspace command doesnthave
    # that means the aircraft has left the airspace 

    current_callsigns_airspace =
      cmd.aircrafts |> Enum.map(fn %{callsign: callsign} -> callsign end)

    exited_events =
      tracked_aircraft
      |> Enum.map(fn callsign ->
        if callsign not in current_callsigns_airspace do
          %AircraftExited{
            zone_id: cmd.zone_id,
            icao24: callsign,
            occurred_at: DateTime.utc_now()
          }
        end
      end)
      |> Enum.reject(&is_nil/1)

    # Return all events
    all_events ++ exited_events
  end

  ## State mutators

  @impl Aggregate
  def apply(
        %Zone{tracked_aircraft: tracked_aircraft} = state,
        %AircraftEntered{} = event
      ) do
    ## when aircraft enters the zone, add to the state
    %{state | zone: event.zone_id, tracked_aircraft: MapSet.put(tracked_aircraft, event.icao24)}
  end

  @impl Aggregate
  def apply(
        %Zone{tracked_aircraft: tracked_aircraft} = state,
        %AircraftExited{} = event
      ) do
    ## when aircraft enters the zone, add to the state
    %{
      state
      | zone: event.zone_id,
        tracked_aircraft: MapSet.delete(tracked_aircraft, event.icao24)
    }
  end
end
