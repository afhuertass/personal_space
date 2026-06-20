defmodule PersonalSpace.Repo.Migrations.AddEventIdToZoneEntries do
  use Ecto.Migration

  def change do
    alter table(:zone_entries) do
      add :event_id, :uuid
    end

    create unique_index(:zone_entries, [:event_id])
  end
end
