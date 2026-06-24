defmodule PersonalSpace.AircraftPoller do
  ## this module is a gen server, it's job is to fetch the data from the opensky api and emmits the commands
  require Logger

  alias PersonalSpace.Zones.Commands.RegisterAirSpace

  defstruct interval_ms: :timer.seconds(60),
            zone_id: "EFHK"

  use GenServer

  def start_link(opts \\ []) do
    initial_state = struct(__MODULE__, opts)
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  @impl true
  def init(init_arg) do
    send(self(), :poll)
    {:ok, init_arg}
  end

  @impl true
  def handle_info(:poll, %__MODULE__{} = state) do
    aircrafts = query_aicrafts()

    # only try to emit the command if there is aircrafts
    if Enum.empty?(aircrafts) do
      IO.inspect("No aicrafts detected")

      Process.send_after(self(), :poll, state.interval_ms)
      {:noreply, state}
    else
      command = %RegisterAirSpace{
        zone_id: state.zone_id,
        aircrafts: aircrafts
      }

      case PersonalSpace.CommandedApp.dispatch(command) do
        :ok ->
          :ok

        {:ok, _} ->
          :ok

        {:error, reason} ->
          Logger.warning("Dispatch failed: #{inspect(reason)}, will retry next poll")
          :ok
      end
    end

    Process.send_after(self(), :poll, state.interval_ms)
    {:noreply, state}
  end

  ## helper functions

  def get_token() do
    client_id = System.get_env("OPENSKY_CLIENT_ID")
    client_secret = System.get_env("OPENSKY_SECRET")

    # Perform the POST request
    response =
      Req.post!(
        "https://auth.opensky-network.org/auth/realms/opensky-network/protocol/openid-connect/token",
        form: [
          grant_type: "client_credentials",
          client_id: client_id,
          client_secret: client_secret
        ]
      )

    response.body["access_token"]
  end

  def query_aicrafts() do
    # the serial of my own litle device
    serial = System.get_env("SERIAL")
    serial = Integer.parse(serial) |> elem(0)

    access_token = get_token()

    params = [
      serials: serial
    ]

    response =
      Req.get!(
        "https://opensky-network.org/api/states/own",
        params: params,
        # Use the token obtained previously
        auth: {:bearer, access_token}
      )

    parse_states(response.body["states"])
  end

  def parse_states(states) when is_nil(states) do
    []
  end

  def parse_states([] = _states) do
    []
  end

  def parse_states(states) when is_list(states) do
    states
    |> Enum.map(fn vector ->
      [
        icao24,
        callsign,
        origin_country,
        time_position,
        last_contact,
        longitude,
        latitude,
        baro_altitude,
        on_ground,
        velocity,
        _ | _
      ] = vector

      %{
        icao24: callsign,
        callsign: callsign,
        origin_country: origin_country,
        time_position: time_position,
        last_contact: last_contact,
        longitude: to_float(longitude),
        latitude: to_float(latitude),
        baro_altitude: to_float(baro_altitude),
        on_ground: on_ground,
        velocity: to_float(velocity)
      }
    end)
  end

  defp to_float(nil), do: nil
  defp to_float(value) when is_float(value), do: value
  defp to_float(value) when is_integer(value), do: value * 1.0
end
