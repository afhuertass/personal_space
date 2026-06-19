defmodule PersonalSpace.CountryFlags do
  @flags %{
    "Finland" => "🇫🇮",
    "Sweden" => "🇸🇪",
    "Norway" => "🇳🇴",
    "Denmark" => "🇩🇰",
    "Estonia" => "🇪🇪",
    "Latvia" => "🇱🇻",
    "Lithuania" => "🇱🇹",
    "Germany" => "🇩🇪",
    "United Kingdom" => "🇬🇧",
    "France" => "🇫🇷",
    "Netherlands" => "🇳🇱",
    "Belgium" => "🇧🇪",
    "Poland" => "🇵🇱",
    "Russia" => "🇷🇺",
    "United States" => "🇺🇸",
    "Canada" => "🇨🇦",
    "China" => "🇨🇳",
    "Japan" => "🇯🇵",
    "South Korea" => "🇰🇷",
    "Australia" => "🇦🇺",
    "Spain" => "🇪🇸",
    "Italy" => "🇮🇹",
    "Switzerland" => "🇨🇭",
    "Austria" => "🇦🇹",
    "Turkey" => "🇹🇷",
    "Ukraine" => "🇺🇦",
    "Colombia" => "🇨🇴",
  }

  def get(country), do: Map.get(@flags, country, "🏳️")
end

