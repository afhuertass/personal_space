defmodule PersonalSpace.Repo.Migrations.ExitedProjector do
  use Ecto.Migration
  use Ecto.Migration

  def change do
    create table(:zone_exits) do
      add :zone_id, :string, null: false
      add :icao24, :string, null: false
      add :origin_country, :string
      add :velocity, :float
      add :baro_altitude, :float
      add :entered_at, :utc_datetime, null: false

      timestamps()
    end

    create index(:zone_exits, [:zone_id])
    create index(:zone_exits, [:icao24])
  end
end
