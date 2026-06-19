defmodule PersonalSpace.Zones.Projections.AircraftsEnter do
  use Ecto.Schema

  schema "zone_entries" do
    field :zone_id, :string
    field :icao24, :string
    field :origin_country, :string
    field :velocity, :float
    field :baro_altitude, :float
    field :entered_at, :utc_datetime_usec
    field :latitude, :float
    field :longitude, :float

    timestamps()
  end
end
