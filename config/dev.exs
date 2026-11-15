import Config

# Configure your database
config :akrasia, Akrasia.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "akrasia_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. We use it with esbuild and
# tailwind to recompile .js and .css sources.
config :akrasia, AkrasiaWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "ov+4IdqoGdI0Moe6GYSgQSgmXpbCgfwU9PyE+GBgTLqMI6jzHi5cJmbW6qK/Trho",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:akrasia, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:akrasia, ~w(--watch)]}
  ]

# Enable dev routes for dashboard and mailbox
config :akrasia, dev_routes: true

# Supervision tree (read by Akrasia.Application, like pan)
config :akrasia, :children, [
  AkrasiaWeb.Telemetry,
  Akrasia.Repo,
  {Phoenix.PubSub, name: Akrasia.PubSub},
  {Akrasia.RateLimit, clean_period: :timer.minutes(1)},
  AkrasiaWeb.Endpoint
]

# Do not include metadata nor timestamps in development logs
config :logger, :default_formatter, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  # Include debug annotations and locations in rendered markup.
  # Changing this configuration will require mix clean and a full recompile.
  debug_heex_annotations: true,
  debug_attributes: true,
  # Enable helpful, but potentially expensive runtime checks
  enable_expensive_runtime_checks: true

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false
