defmodule PersonalSpace.Repo.Migrations.AddintLatitude do
  use Ecto.Migration

  def change do
    alter table(:zone_exits) do
      add :latitude, :float
      add :longitude, :float
    end
  end
end
