defmodule PersonalSpace.CommandedSupervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_options) do
    children = [
      # Here goes my future processess
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
