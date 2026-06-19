defmodule PersonalSpace.Repo.Migrations.ChangeUtcToUtcSecExits do
  use Ecto.Migration

  def change do
    alter table(:zone_exits) do
      modify :occurred_at, :utc_datetime_usec, from: :utc_datetime
    end
  end
end
