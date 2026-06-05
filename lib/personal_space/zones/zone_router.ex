defmodule PersonalSpace.Zones.ZoneRouter do
  use Commanded.Commands.Router

  dispatch(PersonalSpace.Zones.Commands.RegisterEntry,
    to: PersonalSpace.Zones.Aggregates.Zone,
    identity: :zone
  )

  dispatch(PersonalSpace.Zones.Commands.RegisterExit,
    to: PersonalSpace.Zones.Aggregates.Zone,
    identity: :zone
  )
end
