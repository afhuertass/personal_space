defmodule PersonalSpace.Repo.Migrations.ChangeCorrectNames do
  use Ecto.Migration

  def change do
    rename table(:zone_entries), :occurred_at, to: :entered_at

    rename table(:zone_exits), :entered_at, to: :occurred_at
  end
end
