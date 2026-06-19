defmodule PersonalSpace.Bot do
  use TelegramEx, name: :apersonal_space
  alias PersonalSpace.Zones.Queries
  # /start
  def handle(%{"message" => %{"text" => "/start", "chat" => chat}}, context) do
    context
    |> Message.text("""
    ✈️ *Welcome to Personal Space* ✈️

      I track aircraft entering my personal airspace using an ADS\\-B antenna\\.

    *Available commands:*
    /24h \\- Aircrafts detected in the past 24 hours
    /12h \\- Aircrafts detected in the past 12 hours
    /howfar \\- Furthest aircraft detected today
    ...
    """)
    |> Message.send(chat["id"])
  end

  # /24h
  def handle(%{"message" => %{"text" => "/24h", "chat" => chat}}, context) do
    aircrafts = Queries.aircrafts_past24h()

    text = format_aircraft_list(aircrafts, "past 24 hours")

    context
    |> Message.text(text)
    |> Message.send(chat["id"])
  end

  # /12h
  def handle(%{"message" => %{"text" => "/12h", "chat" => chat}}, context) do
    aircrafts = Queries.aicrafts_past12h()

    text = format_aircraft_list(aircrafts, "past 12 hours")

    context
    |> Message.text(text)
    |> Message.send(chat["id"])
  end

  # /howfar
  def handle(%{"message" => %{"text" => "/howfar", "chat" => chat}}, context) do
    # TODO: implement furthest aircraft query
    context
    |> Message.text("🔭 Furthest aircraft: coming soon\\!")
    |> Message.send(chat["id"])
  end

  # --- private helpers ---

  defp format_aircraft_list([], period) do
    "No aircraft detected in the #{period} 😴"
  end

  defp format_aircraft_list(aircrafts, period) do
    header = "✈️ *Aircraft in the #{period}:* #{length(aircrafts)} detected\n\n"

    rows =
      aircrafts
      |> Enum.map(fn a ->
        "🛩 `#{a.icao24}` \\- #{a.origin_country} \\| alt: #{a.baro_altitude}m \\| speed: #{a.velocity}m\\/s"
      end)
      |> Enum.join("\n")

    header <> rows
  end
end
