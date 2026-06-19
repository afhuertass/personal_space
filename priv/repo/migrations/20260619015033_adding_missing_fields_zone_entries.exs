defmodule PersonalSpace.Repo.Migrations.AddingMissingFieldsZoneEntries do
  use Ecto.Migration

  def change do
    alter table(:zone_entries) do
      add :latitude, :float
      add :longitude, :float
    end
  end
end
