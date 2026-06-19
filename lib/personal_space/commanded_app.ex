defmodule PersonalSpace.CommandedApp do
  use Commanded.Application,
    otp_app: :personal_space,
    event_store: [
      adapter: Commanded.EventStore.Adapters.EventStore,
      event_store: PersonalSpace.CommandedEventStore
    ]

  router(PersonalSpace.Zones.ZoneRouter)
end
