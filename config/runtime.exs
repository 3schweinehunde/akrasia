import Config

# config/runtime.exs is executed for all environments, after compilation and
# before the system starts. Secrets and other environment-specific runtime
# values belong here (#9); compile-time configuration does not.

if config_env() == :dev do
  # Reload browser tabs when matching files change.
  config :akrasia, AkrasiaWeb.Endpoint,
    live_reload: [
      web_console_logger: true,
      patterns: [
        ~r"priv/static/(?!uploads/).*\.(js|css|png|jpeg|jpg|gif|svg)$"E,
        ~r"priv/gettext/.*\.po$"E,
        ~r"lib/akrasia_web/router\.ex$"E,
        ~r"lib/akrasia_web/(controllers|live|components)/.*\.(ex|heex)$"E
      ]
    ]
end

if config_env() == :prod do
  # Same environment variables as before the upgrade, so the server setup
  # does not change.
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  config :akrasia, Akrasia.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  config :akrasia, AkrasiaWeb.Endpoint, secret_key_base: secret_key_base
end
