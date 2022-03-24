use Mix.Config

database_url =
  System.get_env("DATABASE_URL") || raise "environment variable DATABASE_URL is missing."

config :akrasia, Akrasia.Repo, url: database_url, pool_size: 10

secret_key_base =
  System.get_env("SECRET_KEY_BASE") || raise "environment variable SECRET_KEY_BASE is missing."

config :akrasia, AkrasiaWeb.Endpoint,
  http: [
    port: 9999,
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base,
  server: true
