import Config

config :akrasia,
  ecto_repos: [Akrasia.Repo]

# Configures the endpoint
config :akrasia, AkrasiaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "kIFJQWZTUQ3chntrpz7N8BJbi4xl7sorCa7Zc8Y17xW+9KjbypRP2ttfg1EIyz5k",
  render_errors: [view: AkrasiaWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Akrasia.PubSub,
  live_view: [signing_salt: "YNVjJjW7"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :akrasia, Akrasia.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "localhost",
  port: 25,
  username: false,
  password: false,
  tls: :if_available,
  ssl: false,
  retries: 1

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.27",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :pid_file, file: "./akrasia.pid"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
