# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

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

config :pan, Akrasia.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "localhost",
  port: 25,
  username: false,
  password: false,
  tls: :if_available,
  ssl: false,
  retries: 1

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
