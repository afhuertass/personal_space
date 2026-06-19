defmodule PersonalSpace.Repo.Migrations.ChangeEnteredAtToUtcDatetimeUsec do
  use Ecto.Migration

  def change do
    alter table(:zone_entries) do
      modify :entered_at, :utc_datetime_usec, from: :utc_datetime
    end
  end
end
