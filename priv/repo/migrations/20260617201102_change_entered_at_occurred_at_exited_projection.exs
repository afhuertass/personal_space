defmodule PersonalSpace.Repo.Migrations.ChangeEnteredAtOccurredAtExitedProjection do
  use Ecto.Migration

  def change do
    rename table(:zone_entries), :entered_at, to: :occurred_at
  end
end
