defmodule PersonalSpace.Repo do
  use Ecto.Repo,
    otp_app: :personal_space,
    adapter: Ecto.Adapters.Postgres
end
