defmodule PersonalSpace.Zones.Aggregates.Zone do
  defstruct zone: nil, tracked_aircraft: MapSet.new()

  alias PersonalSpace.Zones.Aggregates.Zone, as: Zone
  alias Commanded.Aggregates.Aggregate
  ## Commands alias

  alias PersonalSpace.Zones.Commands.RegisterEntry, as: RegisterEntry

  alias PersonalSpace.Zones.Commands.RegisterExit, as: RegisterExit

  ## Alias the events 

  alias PersonalSpace.Zones.Events.AircraftEntered, as: AircraftEntered
  alias PersonalSpace.Zones.Events.AircraftExited, as: AircraftExited

  @behaviour Aggregate

  ## public API

  # Create entered event
  @impl Aggregate
  def execute(
        %Zone{tracked_aircraft: tracked_aircraft},
        %RegisterEntry{} = cmd
      ) do
    # if the plane is in the tracked state already, do nothing
    if MapSet.member?(tracked_aircraft, cmd.icao24) do
      {:ok, []}
    end

    event = %AircraftEntered{
      zone_id: cmd.zone_id,
      icao24: cmd.icao24,
      origin_country: cmd.origin_country,
      time_position: cmd.time_position,
      last_contact: cmd.last_contact,
      longitude: cmd.longitude,
      latitude: cmd.latitude,
      baro_altitude: cmd.baro_altitude,
      on_ground: cmd.on_ground,
      velocity: cmd.velocity,
      occurred_at: DateTime.utc_now()
    }

    {:ok, event}
  end

  # Create left event
  @impl Aggregate
  def execute(
        %Zone{tracked_aircraft: tracked_aircraft},
        %RegisterExit{} = cmd
      ) do
    # if the plane is in the tracked state already, do nothing
    if MapSet.member?(tracked_aircraft, cmd.icao24) do
      event = %AircraftExited{
        zone_id: cmd.zone_id,
        icao24: cmd.icao24,
        origin_country: cmd.origin_country,
        time_position: cmd.time_position,
        last_contact: cmd.last_contact,
        longitude: cmd.longitude,
        latitude: cmd.latitude,
        baro_altitude: cmd.baro_altitude,
        on_ground: cmd.on_ground,
        velocity: cmd.velocity,
        occurred_at: DateTime.utc_now()
      }

      {:ok, event}
    end
  end

  ## State mutators

  @impl Aggregate
  def apply(
        %Zone{tracked_aircraft: tracked_aircraft} = state,
        %AircraftEntered{} = event
      ) do
    ## when aircraft enters the zone, add to the state
    %{state | zone: event.zone_id, tracked_aircraft: MapSet.put(tracked_aircraft, event.icao)}
  end

  @impl Aggregate
  def apply(
        %Zone{tracked_aircraft: tracked_aircraft} = state,
        %AircraftExited{} = event
      ) do
    ## when aircraft enters the zone, add to the state
    %{state | zone: event.zone_id, tracked_aircraft: MapSet.delete(tracked_aircraft, event.icao)}
  end
end
