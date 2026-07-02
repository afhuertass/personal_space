defmodule PersonalSpace.Bot do
  use TelegramEx, name: :apersonal_space

  alias PersonalSpace.Zones.Queries

  alias PersonalSpace.CountryFlags

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
    aircrafts = Queries.aircrafts_past24h() |> Enum.take(10)

    text = format_aircraft_list(aircrafts, "past 24 hours")

    context
    |> Message.text(text)
    |> Message.send(chat["id"])
  end

  # /12h
  def handle_message(%{text: "/12h", chat: chat}, context) do
    aircrafts = Queries.aircrafts_past12h() |> Enum.take(10)

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

  def handle_message(%{text: "/countries12h", chat: chat}, context) do
    country_counts = Queries.countries_count_past12h()

    message = format_country_counts_list(country_counts, "12h")

    context |> Message.text(message) |> Message.send(chat["id"])
  end

  def handle_message(%{text: "/countries24h", chat: chat}, context) do
    country_counts = Queries.countries_count_past24h() |> Enum.take(10)
    IO.inspect(country_counts)

    message = format_country_counts_list(country_counts, "24h")

    context |> Message.text(message) |> Message.send(chat["id"])
  end

  @impl true
  def handle_message(%{text: "/summary", chat: chat}, context) do
    summary_data = Queries.yesterday_summary()
    summary_formatted = format_summary(summary_data)

    context |> Message.text(summary_formatted) |> Message.send(chat["id"])
  end

  def handle_message(%{text: "/map", chat: chat}, context) do
    link = PersonalSpace.KeplerLink.generate()

    context
    |> Message.text("🗺 [Open interactive map](#{link})")
    |> Message.send(chat["id"])
  end

  # --- private helpers ---
  defp format_summary(nil) do
    "📊 No data available for yesterday 😴"
  end

  defp format_summary(%{total_flights: 0}) do
    "📊 No flights detected yesterday 😴"
  end

  defp format_summary(%{
         total_flights: total,
         total_countries: countries,
         most_common: {country, count},
         furthest: {icao, f_country, km},
         busiest_hour: {hour_range, hour_count}
       }) do
    flag = PersonalSpace.CountryFlags.get(country)
    furthest_flag = PersonalSpace.CountryFlags.get(f_country)

    """
    📊 *Yesterday's Airspace Summary*
    ━━━━━━━━━━━━━━━━━━━━
    ✈️  #{total} flights detected
    🌍  #{countries} countries
    🏆  Most common: #{flag} #{country}  - (#{count})
    🔭  Furthest: `#{icao}` #{furthest_flag} #{f_country} — #{km} km
    🕐  Busiest hour: #{hour_range} - (#{hour_count} flights)
    ━━━━━━━━━━━━━━━━━━━━
    """
  end

  defp format_country_counts_list([], period) do
    "No aircraft detected in the #{period} 😴"
  end

  defp format_country_counts_list(country_counts, period) when is_list(country_counts) do
    header = "✈️ *Aircraft in the #{period}:* #{length(country_counts)} countries entering\n\n"

    rows =
      country_counts
      |> Enum.map(fn {country, count} ->
        flag = CountryFlags.get(country)

        "🛩 '#{country}' #{flag}- # #{count} "
      end)
      |> Enum.join("\n")

    header <> rows
  end

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
