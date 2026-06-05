defmodule PersonalSpace.Zones.Projections.AircraftsExited do
  use Ecto.Schema

  schema "zone_exits" do
    field :zone_id, :string
    field :icao24, :string
    field :origin_country, :string
    field :velocity, :float
    field :baro_altitude, :float
    field :entered_at, :utc_datetime

    timestamps()
  end
end

