defmodule PersonalSpace.Repo.Migrations.CreateCurrentAirspace do
  use Ecto.Migration

  def change do
    create table(:current_airspace, primary_key: false) do
      add :icao24, :string, primary_key: true
      add :zone_id, :string, null: false
      add :origin_country, :string
      add :longitude, :float
      add :latitude, :float
      add :baro_altitude, :float
      add :velocity, :float
      add :on_ground, :boolean
      add :time_position, :integer
      add :last_contact, :integer
      add :entered_at, :utc_datetime_usec
      add :last_seen_at, :utc_datetime_usec
      timestamps()
    end

    create index(:current_airspace, [:zone_id])
  end
end
