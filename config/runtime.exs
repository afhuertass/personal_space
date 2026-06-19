import Config

if System.get_env("PHX_SERVER") do
  config :personal_space, PersonalSpaceWeb.Endpoint, server: true
end

config :personal_space, PersonalSpaceWeb.Endpoint,
  http: [port: String.to_integer(System.get_env("PORT", "4000"))]

# Shared across dev and prod
database_url =
  System.get_env("DATABASE_URL") ||
    raise "DATABASE_URL is missing"

database_url_eventstore =
  System.get_env("DATABASE_URL_EVENTSTORE") ||
    raise "DATABASE_URL_EVENTSTORE is missing"

config :personal_space, PersonalSpace.Repo,
  url: database_url,
  ssl: true,
  ssl_opts: [
    verify: :verify_none
  ],
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  # 60s to allow Neon to wake up
  connect_timeout: 60_000,
  queue_target: 10_000,
  queue_interval: 60_000

config :personal_space, PersonalSpace.CommandedEventStore,
  url: database_url_eventstore,
  ssl: true,
  ssl_opts: [
    verify: :verify_none
  ],
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  # 60s to allow Neon to wake up
  connect_timeout: 60_000,
  queue_target: 10_000,
  queue_interval: 60_000

# Production-only config
if config_env() == :prod do
  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :personal_space, PersonalSpace.Repo, socket_options: maybe_ipv6

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
