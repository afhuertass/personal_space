defmodule PersonalSpace.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Poller process
      PersonalSpace.AircraftPoller,

      # event sourcing guys
      PersonalSpace.CommandedApp,
      PersonalSpace.CommandedSupervisor,

      ###
      PersonalSpaceWeb.Telemetry,
      PersonalSpace.Repo,
      {DNSCluster, query: Application.get_env(:personal_space, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PersonalSpace.PubSub},
      # Start a worker by calling: PersonalSpace.Worker.start_link(arg)
      # {PersonalSpace.Worker, arg},
      # Start to serve requests, typically the last entry
      PersonalSpaceWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PersonalSpace.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PersonalSpaceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
