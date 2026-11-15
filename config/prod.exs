import Config

# Prod runs like pan: `mix phx.server` behind nginx (TLS there), with a pid
# file. Akrasia.Repo and the endpoint's secret_key_base are env-var driven,
# see config/runtime.exs.

config :akrasia, AkrasiaWeb.Endpoint,
  # IPv6 any address (dual stack), as before with Cowboy's :inet6
  http: [ip: {0, 0, 0, 0, 0, 0, 0, 0}, port: 9999],
  url: [scheme: "https", host: "akrasia.informatom.com", port: 443],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  check_origin: ["https://akrasia.informatom.com"],
  version: Mix.Project.config()[:version]

# Supervision tree (read by Akrasia.Application, like pan)
config :akrasia, :children, [
  AkrasiaWeb.Telemetry,
  Akrasia.Repo,
  {Phoenix.PubSub, name: Akrasia.PubSub},
  {Akrasia.RateLimit, clean_period: :timer.minutes(1)},
  AkrasiaWeb.Endpoint,
  {PidFile.Worker, file: "akrasia.pid"}
]

# Mail through the local MTA, as before with Bamboo
config :akrasia, Akrasia.Mailer,
  adapter: Swoosh.Adapters.SMTP,
  relay: "localhost",
  port: 25,
  tls: :if_available,
  auth: :never,
  retries: 1

# The SMTP adapter needs no API client
config :swoosh, :api_client, false

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Do not print debug messages in production
config :logger, level: :info
