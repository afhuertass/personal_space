defmodule PersonalSpaceWeb.MapLive do
  use PersonalSpaceWeb, :live_view
  import Ecto.Query
  alias PersonalSpace.Zones.Queries

  @zone_id "EFHK"
  @refresh_interval 1_000

  def mount(_params, _session, socket) do
    if connected?(socket), do: schedule_refresh()
    aircrafts = Queries.current_airspace()
    {:ok, assign(socket, aircrafts: aircrafts, zone_id: @zone_id)}
  end

  def handle_info(:refresh, socket) do
    aircrafts = Queries.current_airspace()
    schedule_refresh()
    {:noreply, assign(socket, aircrafts: aircrafts)}
  end

  defp schedule_refresh do
    Process.send_after(self(), :refresh, @refresh_interval)
  end

  # private functions
  defp format_aircrafts(aircrafts) do
    Enum.map(aircrafts, fn a ->
      %{
        icao24: a.icao24,
        country: a.origin_country,
        lat: a.latitude,
        lon: a.longitude,
        altitude: a.baro_altitude,
        speed: a.velocity
      }
    end)
  end

  # defp schedule_refresh do
  #   Process.send_after(self(), :refresh, @refresh_interval)
  # end

  defp format_altitude(nil), do: "N/A"
  defp format_altitude(alt), do: "#{round(alt)}m"

  defp format_speed(nil), do: "N/A"
  defp format_speed(speed), do: "#{round(speed)}m/s"

  defp format_time(nil), do: "N/A"

  defp format_time(dt) do
    dt
    |> DateTime.shift_zone!("Europe/Helsinki")
    |> Calendar.strftime("%H:%M:%S")
  end
end
