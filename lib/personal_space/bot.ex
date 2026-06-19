defmodule PersonalSpace.Bot do
  use TelegramEx, name: :apersonal_space

  alias PersonalSpace.Zones.Queries

  alias PersonalSpace.CountryFlags
  # /start

  def handle_message(%{"message" => %{"text" => "/start", "chat" => chat}}, context) do
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

  def handle_message(%{text: "/1h", chat: chat}, context) do
    aircrafts = Queries.aircrafts_past1h()

    text = format_aircraft_list(aircrafts, "past 1 hour")

    context
    |> Message.text(text)
    |> Message.send(chat["id"])
  end

  # /24h
  def handle_message(%{text: "/24h", chat: chat}, context) do
    aircrafts = Queries.aircrafts_past24h()

    text = format_aircraft_list(aircrafts, "past 24 hours")

    context
    |> Message.text(text)
    |> Message.send(chat["id"])
  end

  # /12h
  def handle_message(%{text: "/12h", chat: chat}, context) do
    aircrafts = Queries.aircrafts_past12h()

    text = format_aircraft_list(aircrafts, "past 12 hours")

    context
    |> Message.text(text)
    |> Message.send(chat["id"])
  end

  # /howfar
  def handle_message(%{text: "/howfar", chat: chat}, context) do
    # TODO: implement furthest aircraft query
    {icao24, country, _, entered_at, distance} = Queries.furthest_plane()

    time_formatted = format_helsinki_time(entered_at)
    flag = CountryFlags.get(country)

    info_formatted =
      "✈️ Aircraft '#{icao24}' - #{flag} first detected at: #{distance}Km 🕐 #{time_formatted}   "

    context
    |> Message.text(info_formatted)
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
      |> Enum.map(fn {icao24, country, _, entered_at} ->
        flag = CountryFlags.get(country)
        formatted_time = format_helsinki_time(entered_at)
        "🛩 `#{icao24}` - #{country} #{flag} - 🕐 #{formatted_time}"
      end)
      |> Enum.join("\n")

    header <> rows
  end

  defp format_helsinki_time(%DateTime{} = dt) do
    dt
    |> DateTime.shift_zone!("Europe/Helsinki")
    |> Calendar.strftime("%H:%M %d/%m")
  end
end
