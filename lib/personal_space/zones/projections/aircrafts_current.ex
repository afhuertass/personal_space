defmodule PersonalSpace.Zones.Projections.AircraftsCurrent do
  use Ecto.Schema

  @primary_key {:icao24, :string, autogenerate: false}
  schema "current_airspace" do
    field :zone_id, :string
    field :origin_country, :string
    field :longitude, :float
    field :latitude, :float
    field :baro_altitude, :float
    field :velocity, :float
    field :on_ground, :boolean
    field :time_position, :integer
    field :last_contact, :integer
    field :entered_at, :utc_datetime_usec
    field :last_seen_at, :utc_datetime_usec
    timestamps()
  end
end
