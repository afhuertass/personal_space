import Config

config :telegram_ex,
  apersonal_space: System.fetch_env!("TELEGRAM_TOKEN")

if System.get_env("PHX_SERVER") do
  config :personal_space, PersonalSpaceWeb.Endpoint, server: true
end

config :personal_space, PersonalSpaceWeb.Endpoint,
  http: [port: String.to_integer(System.get_env("PORT", "4000"))]

# Production-only config
if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise "DATABASE_URL is missing"

  database_url_eventstore =
    System.get_env("DATABASE_URL_EVENTSTORE") ||
      raise "DATABASE_URL_EVENTSTORE is missing"

  ssl_opts =
    if System.get_env("DB_SSL", "false") == "true" do
      [verify: :verify_none]
    else
      false
    end

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :personal_space, PersonalSpace.Repo,
    url: database_url,
    ssl: ssl_opts,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    connect_timeout: 60_000,
    queue_target: 10_000,
    queue_interval: 60_000,
    socket_options: maybe_ipv6

  config :personal_space, PersonalSpace.CommandedEventStore,
    url: database_url_eventstore,
    ssl: ssl_opts,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    connect_timeout: 60_000,
    queue_target: 10_000,
    queue_interval: 60_000

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise "SECRET_KEY_BASE is missing. Generate one with: mix phx.gen.secret"

  host = System.get_env("PHX_HOST") || "example.com"

  config :personal_space, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :personal_space, PersonalSpaceWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [ip: {0, 0, 0, 0, 0, 0, 0, 0}],
    secret_key_base: secret_key_base
end
