defmodule PersonalSpace.Zones.ZoneRouter do
  use Commanded.Commands.Router

  dispatch(PersonalSpace.Zones.Commands.RegisterEntry,
    to: PersonalSpace.Zones.Aggregates.Zone,
    identity: :zone_id
  )

  dispatch(PersonalSpace.Zones.Commands.RegisterExit,
    to: PersonalSpace.Zones.Aggregates.Zone,
    # identify must be part of the command 
    identity: :zone_id
  )

  dispatch(PersonalSpace.Zones.Commands.RegisterAirSpace,
    to: PersonalSpace.Zones.Aggregates.Zone,
    # identify must be part of the command 
    identity: :zone_id
  )
end
